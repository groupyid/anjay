from flask import request, render_template, jsonify, session, redirect, url_for, send_from_directory
import requests
from werkzeug.security import check_password_hash, generate_password_hash
import logging
from .models import db, User
from .rag_core import get_rag_response, initialize_rag_system
import time
from datetime import datetime
from uuid import uuid4
import json

# ============ Topic Extraction Utilities (phrase-based) ============
import re as _re
import collections as _collections

def _normalize_text(text):
    if not text:
        return ""
    return _re.sub(r"\s+", " ", text.lower()).strip()

# Expanded stopwords including 'cara', interrogatives, and common fillers
STOPWORDS = set([
    'dan','atau','yang','di','ke','dari','untuk','pada','dengan','apa','bagaimana','adalah','saya','ini','itu',
    'the','of','in','to','a','is','are','it','as','by','an','be','on','for','was','were','has','have','had','will','can',
    'petani','chatbot','tolong','mohon','apakah','seperti','agar','yang','jika','bila','dapat','bisa','cara','jelaskan','lebih', 'lanjut', 'pak', 'bu', 'berapa', 'tanam', 'jenis', 'pentingnya', 'saja'
])

# Some phrase starters to avoid as topics
_AVOID_START = {'cara', 'bagaimana', 'apa', 'tolong', 'mohon'}

_TOKEN_RE = _re.compile(r"\b\w+\b", flags=_re.UNICODE)

def tokenize_words(text):
    return _TOKEN_RE.findall(_normalize_text(text))

def extract_phrases(text, ngram_sizes=(2,3)):
    """Extract candidate phrases (bigrams/trigrams) from text, avoiding stopword-only phrases
    and removing phrases starting/ending with stopwords.
    """
    tokens = tokenize_words(text)
    phrases = []
    for n in ngram_sizes:
        if len(tokens) < n:
            continue
        for i in range(len(tokens) - n + 1):
            window = tokens[i:i+n]
            if window[0] in STOPWORDS or window[-1] in STOPWORDS or window[0] in _AVOID_START:
                continue
            # require at least one non-stopword token of length > 2
            if not any((t not in STOPWORDS and len(t) > 2) for t in window):
                continue
            phrase = ' '.join(window)
            phrases.append(phrase)
    return phrases

def extract_best_phrase(text, global_phrase_counts=None):
    """Pick the best phrase from text based on global counts; fallback to the first meaningful word.
    """
    candidates = extract_phrases(text)
    if candidates:
        if global_phrase_counts:
            # choose highest frequency phrase present in text
            candidates_sorted = sorted(candidates, key=lambda p: global_phrase_counts.get(p, 0), reverse=True)
            if candidates_sorted:
                return candidates_sorted[0]
        return candidates[0]
    # fallback to first meaningful word
    for w in tokenize_words(text):
        if w not in STOPWORDS and len(w) > 2 and w not in _AVOID_START:
            return w
    return '-'


def from_json_filter(value):
    import json
    if not value:
        return []
    if isinstance(value, str):
        try:
            return json.loads(value)
        except Exception:
            return []
    return value

def register_routes(app):

    @app.route('/delete_session', methods=['POST'])
    def delete_session():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401
        data = request.get_json()
        session_id = data.get('session_id')
        user_id = session.get('user_id')
        if not session_id:
            return jsonify({'error': 'Session ID tidak valid'}), 400
        from .models import ChatHistory
        print(f"[DEBUG] Hapus session_id={session_id}, user_id={user_id}")
        deleted = ChatHistory.query.filter_by(session_id=session_id).delete()
        db.session.commit()
        print(f"[DEBUG] Jumlah chat dihapus: {deleted}")
        return jsonify({'success': True, 'deleted': deleted})
    # /logout route should only be registered once. Remove duplicate if exists elsewhere.
    app.jinja_env.filters['from_json'] = lambda value: json.loads(value) if value else []

    @app.route('/start_session', methods=['POST'])
    def start_session():
        session_id = str(uuid4())
        return jsonify({'session_id': session_id})

    @app.route('/')
    @app.route('/index')
    def index():
        if 'user_id' not in session:
            return redirect(url_for('login'))
        from .models import ChatHistory
        user_id = session.get('user_id')
        # Ambil semua session milik user, urut terbaru
        all_sessions = db.session.query(ChatHistory.session_id, db.func.min(ChatHistory.created_at))\
            .filter(ChatHistory.user_id == user_id)\
            .group_by(ChatHistory.session_id)\
            .order_by(db.func.max(ChatHistory.created_at).desc())\
            .all()
        sessions = []
        for sid, _ in all_sessions:
            first_chat = ChatHistory.query.filter_by(session_id=sid, user_id=user_id).order_by(ChatHistory.created_at).first()
            if first_chat:
                title = first_chat.question[:40] if first_chat.question else '(Chat Kosong)'
                sessions.append({'session_id': sid, 'title': title})
        # Ambil session aktif dari query param
        session_id = request.args.get('session')
        chats = []
        if session_id:
    
            chats = ChatHistory.query.filter_by(session_id=session_id, user_id=user_id).order_by(ChatHistory.created_at).all()
        elif sessions:
            # Default ke session terbaru jika tidak ada param
            session_id = sessions[0]['session_id']
            chats = ChatHistory.query.filter_by(session_id=session_id, user_id=user_id).order_by(ChatHistory.created_at).all()
        return render_template('index.html', sessions=sessions, active_session=session_id, active_chats=chats)

    @app.route('/test_dashboard')
    def test_dashboard():
        """Simple test dashboard to verify basic functionality"""
        return send_from_directory('.', 'test_dashboard.html')

    @app.route('/dashboard_admin')
    def dashboard_admin():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return redirect(url_for('login'))
        from .models import ChatHistory, User, Region, Province, Regency
        from .topic_modeling import find_topic_clusters
        from sqlalchemy import func
        from datetime import datetime, timedelta
        import collections, re

        now = datetime.utcnow()
        week_ago = now - timedelta(days=7)

        # Province/Regency filter
        selected_region = request.args.get('region', '').strip()  # regency name
        selected_province_id = request.args.get('province_id', '').strip()
        province_obj = None
        if selected_region and not selected_province_id:
            # infer province from regency name for UI selection
            # This part might need adjustment if region names are now short
            reg_obj = Regency.query.filter(func.upper(Regency.name).like(f'%__{selected_region.upper()}%')).first()
            if reg_obj:
                selected_province_id = str(reg_obj.province_id)
        if selected_province_id:
            try:
                province_obj = Province.query.get(int(selected_province_id))
            except (ValueError, TypeError):
                province_obj = None


        # Ensure regencies exist for selected province (auto-seed on demand)
        if selected_province_id:
            try:
                pid_int = int(selected_province_id)
                if Regency.query.filter_by(province_id=pid_int).count() == 0:
                    import requests
                    base = 'https://emsifa.github.io/api-wilayah-indonesia/api'
                    prov = Province.query.get(pid_int)
                    if prov:
                        # Map province name to API id
                        resp = requests.get(f'{base}/provinces.json', timeout=20)
                        resp.raise_for_status()
                        provinces_json = resp.json() or []
                        api_pid = None
                        for pj in provinces_json:
                            if pj.get('name') == prov.name:
                                api_pid = pj.get('id')
                                break
                        if api_pid:
                            rresp = requests.get(f'{base}/regencies/{api_pid}.json', timeout=20)
                            if rresp.status_code == 200:
                                rjson = rresp.json() or []
                                for rj in rjson:
                                    rname = rj.get('name')
                                    if not rname:
                                        continue
                                    exists = Regency.query.filter_by(name=rname, province_id=pid_int).first()
                                    if not exists:
                                        db.session.add(Regency(name=rname, province_id=pid_int))
                                db.session.commit()
            except Exception:
                db.session.rollback()
                # silently ignore, UI will show empty list

        # apply filters
        query = ChatHistory.query.join(User, ChatHistory.user_id == User.id).filter(ChatHistory.created_at >= week_ago)
        if selected_region:
            query = query.filter(func.upper(User.region) == func.upper(selected_region))
        elif selected_province_id:
            try:
                pid_int = int(selected_province_id)
                # Get short names for regencies
                regency_full_names = [r.name for r in Regency.query.filter_by(province_id=pid_int).all()]
                regency_short_names = [name.replace('KABUPATEN ', '').replace('KOTA ', '') for name in regency_full_names]
                if regency_short_names:
                    query = query.filter(User.region.in_(regency_short_names))
            except (ValueError, TypeError):
                pass # Ignore if province_id is invalid
        
        chats = query.all()

        jumlah_pertanyaan = len(chats)

        # --- Topic Modeling and Filtering ---
        # Get time range from request
        time_range = request.args.get('time_range', '1_week') # Default to 1 week

        # Calculate start_time based on time_range
        if time_range == '5_minutes':
            start_time_filter = now - timedelta(minutes=5)
        elif time_range == '4_hours':
            start_time_filter = now - timedelta(hours=4)
        elif time_range == '1_day':
            start_time_filter = now - timedelta(days=1)
        else: # '1_week'
            start_time_filter = now - timedelta(weeks=1)

        # Apply filters to chats
        query_topics = ChatHistory.query.join(User, ChatHistory.user_id == User.id).filter(ChatHistory.created_at >= start_time_filter)
        if selected_region:
            query_topics = query_topics.filter(func.upper(User.region) == func.upper(selected_region))
        elif selected_province_id:
            try:
                pid_int = int(selected_province_id)
                regency_full_names = [r.name for r in Regency.query.filter_by(province_id=pid_int).all()]
                regency_short_names = [name.replace('KABUPATEN ', '').replace('KOTA ', '') for name in regency_full_names]
                if regency_short_names:
                    query_topics = query_topics.filter(User.region.in_(regency_short_names))
            except (ValueError, TypeError):
                pass # Ignore if province_id is invalid
        
        filtered_chats = query_topics.all()

        # Compute phrase counts and top topics
        phrase_counter = _collections.Counter()
        if filtered_chats:
            questions = [c.question for c in filtered_chats if c.question]
            print(f"DEBUG: Dashboard - Processing {len(questions)} questions for topic clustering")
            
            # Try clustering first with error handling
            clustered_topics = []
            try:
                if len(questions) >= 2:  # Minimum data check
                    clustered_topics = find_topic_clusters(questions, min_cluster_size=2)
                else:
                    print(f"DEBUG: Dashboard - Not enough questions for clustering: {len(questions)}")
            except Exception as e:
                print(f"DEBUG: Dashboard - Topic clustering failed: {e}")
                clustered_topics = []
            
            if clustered_topics:
                print(f"DEBUG: Dashboard - Using clustered topics: {len(clustered_topics)}")
                top_topics = clustered_topics
            else:
                print("DEBUG: Dashboard - Fallback to keyword frequency method")
                # Fallback to old method if clustering fails or not enough data
                for c in filtered_chats:
                    phrase_counter.update(extract_phrases(c.question))
                if not phrase_counter:
                    all_questions = ' '.join([c.question or '' for c in filtered_chats]).lower()
                    keywords = _re.findall(r"\b\w+\b", all_questions)
                    keywords = [w for w in keywords if w not in STOPWORDS and len(w) > 2]
                    phrase_counter = _collections.Counter(keywords)

                # Convert old format to new format for compatibility
                top_topics_raw = phrase_counter.most_common(5)
                top_topics = [{'name': name, 'count': count} for name, count in top_topics_raw]
        else:
            top_topics = [] # Ensure top_topics is initialized even if no chats

        all_topics = [t['name'] for t in top_topics] # For filter dropdowns

        

        

        

        

        # All chats for table (join user) - moved up before usage
        user_map = {u.id: u for u in User.query.all()}

        # Generate topic breakdown by region (This part needs to be adapted for new topics)
        # For now, this will be empty as it depends on the old phrase_counter

        # All region & topic for filter (union Region master + user regions)
        user_regions = [u.region for u in User.query.filter(User.region != None).with_entities(User.region).all()]
        master_regions = [r.name for r in Region.query.order_by(Region.name.asc()).all()]
        all_regions = sorted(set([r for r in user_regions if r] + master_regions))
        
        # This part needs to be adapted for new topics
        def extract_topik(q):
            # This is a placeholder; a better approach would be to classify a new question
            # into one of the existing topic clusters.
            return extract_best_phrase(q, global_phrase_counts=phrase_counter)

        all_chats = [
            {
                'question': c.question,
                'answer': c.answer,
                'created_at': c.created_at,
                'user_name': user_map[c.user_id].name if c.user_id in user_map else '-',
                'region': user_map[c.user_id].region if c.user_id in user_map and user_map[c.user_id].region else '-',
                'topik': extract_topik(c.question)
            }
            for c in chats
        ]

        # Insight perilaku pengguna
        jam_counter = _collections.Counter([c.created_at.hour for c in chats if c.created_at])
        jam_aktif_tertinggi = f"{jam_counter.most_common(1)[0][0]}:00" if jam_counter else '-'
        user_counter = _collections.Counter([c.user_id for c in chats if c.user_id])
        rata2_pertanyaan_per_user = f"{(jumlah_pertanyaan/len(user_counter)):.2f}" if user_counter else '-'

        # Wilayah aktif (tanpa koordinat atau username)
        regions_set = set()
        for c in chats:
            if c.user_id in user_map and user_map[c.user_id].region:
                regions_set.add(user_map[c.user_id].region)
        regions_in_chats = sorted(regions_set)
        wilayah_aktif = ', '.join(regions_in_chats) if regions_in_chats else '-'

        # Early Warning System (setelah data tersedia)
        ews = []
        ews_map = {}
        for c in chats:
            user = user_map.get(c.user_id)
            region = user.region if user and user.region else '-'
            topik = extract_topik(c.question)
            key = (region, topik)
            if key not in ews_map:
                ews_map[key] = {'users': set(), 'count': 0}
            if c.user_id:
                ews_map[key]['users'].add(c.user_id)
            ews_map[key]['count'] += 1
        for (region, topik), v in ews_map.items():
            if region != '-' and topik != '-' and len(v['users']) >= 3 and v['count'] >= 5:
                ews.append({
                    'region': region,
                    'topik': topik,
                    'user_count': len(v['users']),
                    'chat_count': v['count']
                })

        
        topic_by_region = [] # Placeholder to resolve NameError
        return render_template('dashboard_admin.html',
            user=session.get('user_name'),
            jumlah_pertanyaan=jumlah_pertanyaan,
            top_topics=top_topics,
            wilayah_aktif=wilayah_aktif,
            all_regions=all_regions,
            all_topics=all_topics,
            all_chats=all_chats,
            jam_aktif_tertinggi=jam_aktif_tertinggi,
            rata2_pertanyaan_per_user=rata2_pertanyaan_per_user,
            ews=ews,
            topic_by_region=topic_by_region,
            selected_region=selected_region,
            selected_province_id=selected_province_id or ''
        )



    @app.route('/login', methods=['GET', 'POST'])
    def login():
        print("DEBUG: Login route accessed.")
        print(f"DEBUG: Session before processing: {session}")
        if 'user_id' in session:
            if session.get('user_role') == 'admin':
                return redirect(url_for('dashboard_admin'))
            return redirect(url_for('index'))
        if request.method == 'POST':
            email = request.form['email']
            password = request.form['password']
            user = User.query.filter_by(email=email).first()
            if user and check_password_hash(user.password, password):
                session['user_id'] = user.id
                session['user_name'] = user.name
                session['is_admin'] = user.role == 'admin'
                session['user_role'] = user.role
                session['admin_region'] = user.region
                print(f"DEBUG: Login successful. Session after login: {session}")
                if user.role == 'admin':
                    return redirect(url_for('dashboard_admin'))
                else:
                    session_id = str(uuid4())
                    return redirect(url_for('index', session=session_id))
            else:
                print("DEBUG: Login failed. Flashing error message.")
                from flask import flash
                flash("Email atau password salah.", "error")
                print(f"DEBUG: Session after flash: {session}")
                return redirect(url_for('login'))
        print(f"DEBUG: Session before rendering login.html (GET request): {session}")
        return render_template('login.html')

    @app.route('/daftar', methods=['GET', 'POST'])
    def daftar_petani():
        if 'user_id' in session:
            return redirect(url_for('index'))
        if request.method == 'POST':
            data = request.form
            if User.query.filter_by(email=data['email']).first():
                return render_template('daftar.html', error="Email sudah terdaftar.")
            user = User(
                name=data['name'],
                dob=datetime.strptime(data['dob'], '%Y-%m-%d'),
                gender=data['gender'],
                email=data['email'],
                phone=data['phone'],
                password=generate_password_hash(data['password']),
                role='petani'
            )
            db.session.add(user)
            db.session.commit()
            return redirect(url_for('login'))
        return render_template('daftar.html')

    @app.route('/update_location', methods=['POST'])
    def update_location():
        if 'user_id' not in session:
            return jsonify({'status': 'error', 'message': 'Unauthorized'}), 401
        
        data = request.get_json()
        if not data or 'latitude' not in data or 'longitude' not in data:
            return jsonify({'status': 'error', 'message': 'Invalid location data'}), 400
            
        user = User.query.get(session['user_id'])
        if not user:
            return jsonify({'status': 'error', 'message': 'User not found'}), 404
            
        try:
            lat = float(data['latitude'])
            lon = float(data['longitude'])
            
            print(f"DEBUG: Updating location for user {user.name}: {lat}, {lon}")
            
            # Update user's current location
            user.latitude = lat
            user.longitude = lon
            detected_region = None

            # Reverse Geocoding using OpenStreetMap
            try:
                headers = {'User-Agent': 'PaTaniApp/1.0'}
                url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}&accept-language=id"
                response = requests.get(url, headers=headers, timeout=10)
                response.raise_for_status()
                geo_data = response.json()
                
                print(f"DEBUG: Geocoding response: {geo_data}")
                
                if 'address' in geo_data:
                    # Enhanced region detection with priority order
                    address = geo_data['address']
                    
                    # Priority order for Indonesian administrative regions
                    region_candidates = [
                        address.get('county'),           # Kabupaten/Kota
                        address.get('city'),            # Kota
                        address.get('state_district'),  # Kecamatan
                        address.get('state'),           # Provinsi  
                        address.get('municipality'),    # Kotamadya
                        address.get('village'),         # Desa/Kelurahan
                        address.get('town'),            # Kota kecil
                    ]
                    
                    # Find first non-empty region
                    for candidate in region_candidates:
                        if candidate and candidate.strip():
                            detected_region = candidate.strip().upper()
                            user.region = detected_region
                            print(f"DEBUG: Region detected: {detected_region}")
                            break
                    
                    if not detected_region:
                        # Fallback to country if no specific region found
                        country = address.get('country', '')
                        if 'indonesia' in country.lower():
                            detected_region = 'INDONESIA'
                            user.region = detected_region
                            print(f"DEBUG: Fallback to country: {detected_region}")

            except requests.exceptions.RequestException as e:
                print(f"WARNING: Reverse geocoding failed: {e}")
                detected_region = None
            except Exception as e:
                print(f"ERROR: Unexpected geocoding error: {e}")
                detected_region = None

            # Commit changes to database
            db.session.commit()
            
            response_data = {
                'status': 'success',
                'message': 'Location updated successfully',
                'latitude': lat,
                'longitude': lon
            }
            
            # Include detected region in response if available
            if detected_region:
                response_data['region'] = detected_region
                response_data['message'] = f'Location updated successfully. Region: {detected_region}'
            
            print(f"DEBUG: Location update response: {response_data}")
            return jsonify(response_data)
            
        except ValueError as e:
            print(f"ERROR: Invalid coordinate values: {e}")
            return jsonify({'status': 'error', 'message': 'Invalid coordinate values'}), 400
        except Exception as e:
            print(f"ERROR: Database error during location update: {e}")
            db.session.rollback()
            return jsonify({'status': 'error', 'message': 'Failed to update location'}), 500

    @app.route('/logout')
    def logout():
        session.clear()
        return redirect(url_for('login'))

    
    
    @app.route('/chat', methods=['POST'])
    def chat():
        if 'user_id' not in session:
            return jsonify({'error': 'Unauthorized'}), 401
        """Optimized chat endpoint with better error handling and performance"""
        start_time = time.time()
        try:
            # Validate request
            if not request.is_json:
                return jsonify({'error': 'Request must be JSON'}), 400
            
            data = request.get_json()
            if not data or 'message' not in data:
                return jsonify({'error': 'Message is required'}), 400
            
            user_question = data['message'].strip()
            if not user_question:
                return jsonify({'error': 'Message cannot be empty'}), 400
            
            # Limit message length
            if len(user_question) > 1000:
                return jsonify({'error': 'Message too long. Please keep it under 1000 characters.'}), 400
            
            history = data.get('history', [])
            
            # Limit history to prevent context overflow
            if len(history) > 10:
                history = history[-10:]
            
            
            # Get response from optimized RAG system
            response_text, sources = get_rag_response(user_question, history)
            # Jika jawaban adalah pesan default/tidak relevan, kosongkan sources
            if response_text.strip().lower().startswith("mohon maaf") or response_text.strip().lower().startswith("maaf, pertanyaan anda"):
                sources = []

            # Simpan ke riwayat chat jika user login
            from .models import ChatHistory
            session_id = data.get('session_id')
            user_id = session.get('user_id')
            if not session_id:
                # Buat session baru jika tidak ada
                session_id = str(uuid4())
            chat_entry = ChatHistory(
                user_id=user_id,
                question=user_question,
                answer=response_text,
                sources=json.dumps(sources) if sources else None,
                session_id=session_id
            )
            db.session.add(chat_entry)
            db.session.commit()

            processing_time = time.time() - start_time

            return jsonify({
                'reply': response_text,
                'sources': sources,
                'processing_time': round(processing_time, 2),
                'session_id': session_id
            })
        except Exception as e:
            error_id = int(time.time())
            logging.exception(f"[ERROR][chat] ID: {error_id}")
            # Jika mode debug, tampilkan error detail di response
            import os
            debug = os.environ.get('FLASK_DEBUG', '0') == '1'
            return jsonify({
                'reply': f"Maaf, terjadi kesalahan server (ID: {error_id}). Silakan coba lagi atau hubungi administrator jika masalah berlanjut.",
                'error_id': error_id,
                'error_detail': str(e) if debug else None
            }), 500

    @app.route('/chat/health', methods=['GET'])
    def chat_health():
        """Health check endpoint for chat system"""
        try:
            # Quick test of RAG system
            test_response, _ = get_rag_response("test", [])
            
            return jsonify({
                'status': 'healthy',
                'rag_system': 'operational' if test_response else 'unavailable',
                'timestamp': datetime.utcnow().isoformat()
            })
        except Exception as e:
            return jsonify({
                'status': 'unhealthy',
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            }), 500

    @app.route('/chat/init', methods=['POST'])
    def initialize_chat():
        """Endpoint to manually initialize RAG system"""
        try:
            initialize_rag_system()
            return jsonify({
                'status': 'initializing',
                'message': 'RAG system initialization started'
            })
        except Exception as e:
            return jsonify({
                'status': 'error',
                'message': str(e)
            }), 500

    @app.route('/api/admin/provinces', methods=['GET'])
    def api_admin_provinces():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import Province, Regency
        provs = Province.query.order_by(Province.name.asc()).all()
        if not provs:
            # Auto-seed once from public API if empty
            try:
                import requests
                base = 'https://emsifa.github.io/api-wilayah-indonesia/api'
                # fetch provinces
                resp = requests.get(f'{base}/provinces.json', timeout=20)
                resp.raise_for_status()
                provinces_json = resp.json() or []
                for pj in provinces_json:
                    name = pj.get('name')
                    if not name:
                        continue
                    if not Province.query.filter_by(name=name).first():
                        db.session.add(Province(name=name))
                db.session.commit()
                # fetch regencies per province
                provs = Province.query.order_by(Province.name.asc()).all()
                for p in provs:
                    # find id from API by matching name
                    api_pid = None
                    for pj in provinces_json:
                        if pj.get('name') == p.name:
                            api_pid = pj.get('id')
                            break
                    if not api_pid:
                        continue
                    rresp = requests.get(f'{base}/regencies/{api_pid}.json', timeout=20)
                    if rresp.status_code != 200:
                        continue
                    rjson = rresp.json() or []
                    for rj in rjson:
                        rname = rj.get('name')
                        if not rname:
                            continue
                        exists = Regency.query.filter_by(name=rname, province_id=p.id).first()
                        if not exists:
                            db.session.add(Regency(name=rname, province_id=p.id))
                db.session.commit()
                provs = Province.query.order_by(Province.name.asc()).all()
            except Exception:
                db.session.rollback()
                # fall back to empty if seeding fails
        return jsonify({'provinces': [{'id': p.id, 'name': p.name} for p in provs]})

    @app.route('/api/admin/seed-indonesia-regions', methods=['POST'])
    def api_admin_seed_indonesia_regions():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import Province, Regency
        try:
            import requests
            base = 'https://emsifa.github.io/api-wilayah-indonesia/api'
            resp = requests.get(f'{base}/provinces.json', timeout=30)
            resp.raise_for_status()
            provinces_json = resp.json() or []
            name_to_id = {}
            for pj in provinces_json:
                name = pj.get('name')
                if not name:
                    continue
                p = Province.query.filter_by(name=name).first()
                if not p:
                    p = Province(name=name)
                    db.session.add(p)
                    db.session.flush()
                name_to_id[name] = (pj.get('id'), p.id)
            db.session.commit()
            count_regs = 0
            for name, (api_id, db_id) in name_to_id.items():
                try:
                    rresp = requests.get(f'{base}/regencies/{api_id}.json', timeout=30)
                    rresp.raise_for_status()
                    rjson = rresp.json() or []
                    for rj in rjson:
                        rname = rj.get('name')
                        if not rname:
                            continue
                        exists = Regency.query.filter_by(name=rname, province_id=db_id).first()
                        if not exists:
                            db.session.add(Regency(name=rname, province_id=db_id))
                            count_regs += 1
                    db.session.commit()
                except Exception:
                    db.session.rollback()
                    continue
            return jsonify({'ok': True, 'provinces': len(name_to_id), 'regencies_added': count_regs})
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': 'Seeding gagal'}), 500

    @app.route('/api/admin/regencies', methods=['GET'])
    def api_admin_regencies():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import Regency, Province
        try:
            pid = int(request.args.get('province_id', '0'))
        except Exception:
            pid = 0
        if not pid:
            return jsonify({'regencies': []})
        regs = Regency.query.filter_by(province_id=pid).order_by(Regency.name.asc()).all()
        # Auto-seed regencies for this province if empty
        if not regs:
            try:
                import requests
                base = 'https://emsifa.github.io/api-wilayah-indonesia/api'
                prov = Province.query.get(pid)
                if prov:
                    resp = requests.get(f'{base}/provinces.json', timeout=20)
                    resp.raise_for_status()
                    provinces_json = resp.json() or []
                    api_pid = None
                    for pj in provinces_json:
                        if pj.get('name') == prov.name:
                            api_pid = pj.get('id')
                            break
                    if api_pid:
                        rresp = requests.get(f'{base}/regencies/{api_pid}.json', timeout=20)
                        if rresp.status_code == 200:
                            rjson = rresp.json() or []
                            for rj in rjson:
                                rname = rj.get('name')
                                if not rname:
                                    continue
                                exists = Regency.query.filter_by(name=rname, province_id=pid).first()
                                if not exists:
                                    db.session.add(Regency(name=rname, province_id=pid))
                            db.session.commit()
                            regs = Regency.query.filter_by(province_id=pid).order_by(Regency.name.asc()).all()
            except Exception:
                db.session.rollback()
                regs = []
        return jsonify({'regencies': [{'id': r.id, 'name': r.name} for r in regs]})

    # --- Regions master management ---
    @app.route('/api/admin/regions', methods=['GET', 'POST'])
    def api_admin_regions():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import Region, User
        if request.method == 'GET':
            master = [r.name for r in Region.query.order_by(Region.name.asc()).all()]
            user_regions = [r[0] for r in User.query.filter(User.region != None).with_entities(User.region).distinct().all()]
            all_regions = sorted(set([*(master or []), *([ur for ur in user_regions if ur] or [])]))
            return jsonify({'regions': all_regions, 'master': master})
        # POST: add new region
        try:
            data = request.get_json() or {}
            name = (data.get('name') or '').strip()
            if not name:
                return jsonify({'error': 'Nama wilayah wajib diisi'}), 400
            exists = Region.query.filter(Region.name.ilike(name)).first()
            if exists:
                return jsonify({'ok': True, 'message': 'Wilayah sudah ada'}), 200
            reg = Region(name=name)
            db.session.add(reg)
            db.session.commit()
            return jsonify({'ok': True, 'name': name}), 201
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': 'Gagal menambah wilayah'}), 500

    @app.route('/api/admin/trends', methods=['GET'])
    def api_admin_trends():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import ChatHistory, User, Regency, Province
        from datetime import timedelta
        import collections, re

        time_filter = request.args.get('time_filter', '1_week').lower() # 15_minutes|4_hours|1_day|1_week|1_month|all_time
        try:
            top_k = int(request.args.get('top_k', '5'))
        except Exception:
            top_k = 5

        region_filter = request.args.get('region', '').strip()
        province_id = request.args.get('province_id', '').strip()

        # Ensure regencies exist for requested province
        if province_id:
            try:
                pid_int = int(province_id)
                if Regency.query.filter_by(province_id=pid_int).count() == 0:
                    import requests
                    base = 'https://emsifa.github.io/api-wilayah-indonesia/api'
                    prov = Province.query.get(pid_int)
                    if prov:
                        resp = requests.get(f'{base}/provinces.json', timeout=20)
                        resp.raise_for_status()
                        provinces_json = resp.json() or []
                        api_pid = None
                        for pj in provinces_json:
                            if pj.get('name') == prov.name:
                                api_pid = pj.get('id')
                                break
                        if api_pid:
                            rresp = requests.get(f'{base}/regencies/{api_pid}.json', timeout=20)
                            if rresp.status_code == 200:
                                rjson = rresp.json() or []
                                for rj in rjson:
                                    rname = rj.get('name')
                                    if not rname:
                                        continue
                                    exists = Regency.query.filter_by(name=rname, province_id=pid_int).first()
                                    if not exists:
                                        db.session.add(Regency(name=rname, province_id=pid_int))
                                db.session.commit()
            except Exception:
                db.session.rollback()
                # ignore

        now = datetime.utcnow()
        start_time = None
        if time_filter == '15_minutes':
            start_time = now - timedelta(minutes=15)
        elif time_filter == '4_hours':
            start_time = now - timedelta(hours=4)
        elif time_filter == '1_day':
            start_time = now - timedelta(days=1)
        elif time_filter == '1_week':
            start_time = now - timedelta(weeks=1)
        elif time_filter == '1_month':
            start_time = now - timedelta(days=30) # Approximate for a month
        # If time_filter is 'all_time', start_time remains None
        query = ChatHistory.query.join(User, ChatHistory.user_id == User.id)
        if start_time:
            query = query.filter(ChatHistory.created_at >= start_time)

        if region_filter:
            query = query.filter(User.region == region_filter)
        elif province_id:
            # SIMPLE ID-BASED FILTERING (New normalized approach)
            try:
                pid_int = int(province_id)
                print(f"DEBUG: Simple province filter - province_id={pid_int}")
                
                # Primary strategy: Use province_id foreign key (new normalized data)
                id_based_query = query.filter(User.province_id == pid_int)
                id_count = id_based_query.count()
                print(f"DEBUG: Found {id_count} chats using province_id FK")
                
                if id_count > 0:
                    # Use ID-based query if we have normalized data
                    query = id_based_query
                else:
                    # Fallback to text-based search for legacy data
                    print(f"DEBUG: No FK data found, falling back to text search")
                    province = Province.query.get(pid_int)
                    if province:
                        province_name = province.name.lower()
                        
                        # Build search conditions with aliases for backward compatibility
                        search_conditions = [db.func.lower(User.region).contains(province_name)]
                        
                        # Special handling for Jakarta
                        if 'jakarta' in province_name or 'dki' in province_name:
                            jakarta_aliases = ['jakarta', 'dki jakarta', 'dki', 'jakarta pusat', 
                                             'jakarta utara', 'jakarta selatan', 'jakarta timur', 'jakarta barat']
                            for alias in jakarta_aliases:
                                search_conditions.append(db.func.lower(User.region).contains(alias))
                            print(f"DEBUG: Added Jakarta aliases for backward compatibility")
                        
                        # Apply text search with OR conditions
                        query = ChatHistory.query.join(User, ChatHistory.user_id == User.id) \
                            .filter(db.or_(*search_conditions))
                        if start_time:
                            query = query.filter(ChatHistory.created_at >= start_time)
                        print(f"DEBUG: Text fallback found {query.count()} chats for province '{province_name}'")
                    else:
                        query = query.filter(False) # No results
                        print(f"DEBUG: Province {province_id} not found")
            except ValueError:
                # Invalid province_id, return empty result
                query = query.filter(False) # No results
                print(f"DEBUG: Invalid province_id: {province_id}")
                print(f"DEBUG: Invalid province_id: {province_id}")
            except Exception as e:
                # Handle any other database errors
                query = query.filter(False) # No results
                print(f"DEBUG: Database error for province_id {province_id}: {str(e)}")
        
        chats = query.all()

        # Compute phrase counts across chats and choose a best phrase per chat
        phrase_counts = _collections.Counter()
        chat_best_phrase = {}
        for c in chats:
            phs = extract_phrases(c.question)
            phrase_counts.update(phs)
        # Fallback to keywords when phrase extraction yields nothing
        if not phrase_counts:
            all_questions = ' '.join([(c.question or '') for c in chats]).lower()
            keywords = _re.findall(r"\b\w+\b", all_questions)
            keywords = [w for w in keywords if w not in STOPWORDS and len(w) > 2]
            phrase_counts = _collections.Counter(keywords)
        for c in chats:
            chat_best_phrase[c.id] = extract_best_phrase(c.question, global_phrase_counts=phrase_counts)

        def bucket_start(dt):
            if time_filter == '15_minutes':
                # Round down to the nearest 15 minutes
                minute = (dt.minute // 15) * 15
                return datetime(dt.year, dt.month, dt.day, dt.hour, minute)
            if time_filter == '4_hours':
                # Round down to the nearest 4 hours
                hour = (dt.hour // 4) * 4
                return datetime(dt.year, dt.month, dt.day, dt.hour, hour)
            if time_filter == '1_day':
                return datetime(dt.year, dt.month, dt.day)
            if time_filter == '1_week':
                # set to Monday 00:00
                monday = dt - timedelta(days=dt.weekday())
                return datetime(monday.year, monday.month, monday.day)
            if time_filter == '1_month':
                return datetime(dt.year, dt.month, 1)
            # all_time or fallback
            return datetime(dt.year, dt.month, dt.day)

        def next_bucket(dt, time_filter):
            if time_filter == '15_minutes':
                return dt + timedelta(minutes=15)
            elif time_filter == '4_hours':
                return dt + timedelta(hours=4)
            elif time_filter == '1_day':
                return dt + timedelta(days=1)
            elif time_filter == '1_week':
                return dt + timedelta(weeks=7) # Add 7 days for a week
            elif time_filter == '1_month':
                # For month, add 30 days as an approximation, or use more complex date logic
                return dt + timedelta(days=30)
            return dt + timedelta(days=1) # Default to 1 day

        # Aggregate counts
        totals_by_topic = collections.Counter()
        counts = {}
        for c in chats:
            if not c.created_at:
                continue
            bucket = bucket_start(c.created_at)
            topic = chat_best_phrase.get(c.id, '-')
            if topic == '-':
                continue
            totals_by_topic[topic] += 1
            counts.setdefault(bucket, {}).setdefault(topic, 0)
            counts[bucket][topic] += 1

        top_topics = [t for t, _ in totals_by_topic.most_common(top_k)]
        # Build sorted bucket labels
        labels = sorted(counts.keys())
        # Ensure continuous buckets and also build when no data
        if labels:
            filled = []
            cursor = labels[0]
            last = labels[-1]
            while cursor <= last:
                filled.append(cursor)
                cursor = next_bucket(cursor, time_filter)
            labels = filled
        elif time_filter == 'all_time':
            labels = [datetime.min] # A single bucket for all time
        else:
            # No data: still generate timeline buckets for the selected range
            start_bucket = bucket_start(start_time)
            end_bucket = bucket_start(now)
            cursor = start_bucket
            labels = []
            max_steps = 1000
            while cursor <= end_bucket and max_steps > 0:
                labels.append(cursor)
                cursor = next_bucket(cursor, time_filter)
                max_steps -= 1

        # Build matrix
        matrix = []
        for topic in top_topics:
            row = []
            for b in labels:
                row.append(counts.get(b, {}).get(topic, 0))
            matrix.append(row)

        # Serialize labels
        if time_filter == '15_minutes':
            label_strings = [b.strftime('%Y-%m-%d %H:%M') for b in labels]
        elif time_filter == '4_hours':
            label_strings = [b.strftime('%Y-%m-%d %H:00') for b in labels]
        elif time_filter == '1_day':
            label_strings = [b.strftime('%Y-%m-%d') for b in labels]
        elif time_filter == '1_week':
            label_strings = [b.strftime('%Y-%m-%d (Week %W)') for b in labels]
        elif time_filter == '1_month':
            label_strings = [b.strftime('%Y-%m') for b in labels]
        elif time_filter == 'all_time':
            label_strings = ['All Time']
        else:
            label_strings = [b.strftime('%Y-%m-%d') for b in labels] # Default fallback
        return jsonify({
            'labels': label_strings,
            'topics': top_topics,
            'matrix': matrix
        })

    @app.route('/api/admin/topic-distribution', methods=['GET'])
    def api_admin_topic_distribution():
        print("DEBUG: api_admin_topic_distribution accessed.")
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        from .models import ChatHistory, User
        from datetime import timedelta
        
        try:
            today = datetime.now()
            
            # Get request parameters
            topic_filter = request.args.get('topic', '').strip()
            days_param = request.args.get('days', '30')
            try:
                days = int(days_param)
            except ValueError:
                days = 30
            
            province_id = request.args.get('province_id', '').strip()
            region_filter = request.args.get('region', '').strip()
            time_range = request.args.get('time_range', '1_week')
            
            print(f"DEBUG: Parameters - topic: {topic_filter}, days: {days}, province: {province_id}, region: {region_filter}, time_range: {time_range}")
            
            # Apply time range filter
            date_filter = today
            if time_range == '5_minutes':
                date_filter = today - timedelta(minutes=5)
            elif time_range == '4_hours':
                date_filter = today - timedelta(hours=4)
            elif time_range == '1_day':
                date_filter = today - timedelta(days=1)
            elif time_range == '1_week':
                date_filter = today - timedelta(weeks=1)
            
            cutoff = today - timedelta(days=days)
            
            # Build base query with time range
            query = ChatHistory.query.join(User).filter(
                ChatHistory.created_at >= cutoff,
                ChatHistory.created_at >= date_filter
            )
            
            # Apply region filter
            if region_filter:
                query = query.filter(User.region.ilike(f'%{region_filter}%'))
            
            if province_id:
                print(f"DEBUG: Topic distribution filter - province_id={province_id}")
                
                # Primary strategy: Use province_id foreign key (new normalized data)
                id_based_query = query.filter(User.province_id == province_id)
                id_count = id_based_query.count()
                print(f"DEBUG: Found {id_count} chats using province_id FK")
                
                if id_count > 0:
                    # Use ID-based query if we have normalized data
                    query = id_based_query
                else:
                    # Fallback to text-based search for legacy data
                    print(f"DEBUG: No FK data found, falling back to text search")
                    from .models import Province
                    province = Province.query.get(province_id)
                    
                    if province:
                        province_name = province.name
                        province_aliases = [province_name]
                        
                        # Special handling for Jakarta
                        if 'Jakarta' in province_name or 'DKI' in province_name:
                            province_aliases.extend(['Jakarta', 'DKI Jakarta', 'DKI', 'Jakarta Pusat', 
                                                   'Jakarta Utara', 'Jakarta Selatan', 'Jakarta Timur', 'Jakarta Barat'])
                            print(f"DEBUG: Added Jakarta aliases: {province_aliases}")
                        
                        print(f"DEBUG: Text search terms for province {province_id}: {province_aliases}")
                        
                        # Apply text-based search with aliases
                        conditions = [User.region.ilike(f'%{name}%') for name in province_aliases]
                        query = query.filter(db.or_(*conditions))
                    else:
                        query = query.filter(User.region == '__NO_MATCH__')  # No results if province not found
            
            chats = query.all()
            print(f"DEBUG: Found {len(chats)} chats matching criteria")
            
            # Filter by topic if specified
            if topic_filter:
                chats = [chat for chat in chats if topic_filter.lower() in chat.question.lower()]
                print(f"DEBUG: After topic filter: {len(chats)} chats")
            
            # Group by region and calculate coordinates
            region_counts = {}
            for chat in chats:
                if chat.user and chat.user.region:
                    region = chat.user.region.strip()
                    if region:
                        if region not in region_counts:
                            region_counts[region] = {'count': 0}
                        region_counts[region]['count'] += 1
            
            print(f"DEBUG: Region counts: {region_counts}")
            
            # Get coordinates for regions and create markers
            markers = []
            for region, data in region_counts.items():
                try:
                    lat, lon = get_region_coordinates(region)
                    if lat is not None and lon is not None:
                        markers.append({
                            'region': region,
                            'count': data['count'],
                            'lat': lat,
                            'lon': lon,
                            'topic': topic_filter or 'Semua'
                        })
                        print(f"DEBUG: Added marker for {region} at [{lat}, {lon}] with {data['count']} chats")
                    else:
                        print(f"DEBUG: No coordinates found for region: {region}")
                except Exception as e:
                    print(f"DEBUG: Error getting coordinates for {region}: {e}")
            
            # If no markers found, provide sample data for testing
            if not markers:
                sample_markers = [
                    {
                        'region': 'Jakarta',
                        'count': 15,
                        'lat': -6.2088,
                        'lon': 106.8456,
                        'topic': topic_filter or 'Sample Data'
                    },
                    {
                        'region': 'Surabaya', 
                        'count': 8,
                        'lat': -7.2575,
                        'lon': 112.7521,
                        'topic': topic_filter or 'Sample Data'
                    },
                    {
                        'region': 'KOTA BANDUNG',
                        'count': 5,
                        'lat': -6.9175,
                        'lon': 107.6191,
                        'topic': topic_filter or 'Sample Data'
                    }
                ]
                print("DEBUG: No real data found, returning sample markers for testing")
                return jsonify({'markers': sample_markers, 'note': 'Sample data - no real chat data found'})
            
            print(f"DEBUG: Returning {len(markers)} real markers")
            return jsonify({'markers': markers})
            
        except Exception as e:
            print(f"ERROR in api_admin_topic_distribution: {e}")
            import traceback
            traceback.print_exc()
            return jsonify({'error': f'Server error: {str(e)}'}), 500

    # New API routes for enhanced admin functionality
    


    @app.route('/api/admin/users/<int:user_id>', methods=['GET'])
    def api_admin_get_user(user_id):
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User
        try:
            user = User.query.get_or_404(user_id)
            user_data = {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'phone': user.phone,
                'role': user.role,
                'region': user.region,
                'created_at': user.created_at.isoformat(),
                'latitude': user.latitude,
                'longitude': user.longitude
            }
            return jsonify({'user': user_data})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/users', methods=['POST'])
    def api_admin_create_user():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User
        from werkzeug.security import generate_password_hash
        from datetime import date
        
        try:
            data = request.get_json()
            
            # Check if email already exists
            existing_user = User.query.filter_by(email=data['email']).first()
            if existing_user:
                return jsonify({'error': 'Email already exists'}), 400
            
            # Create new user
            new_user = User(
                name=data['name'],
                email=data['email'],
                phone=data['phone'],
                password=generate_password_hash(data['password']),
                role=data.get('role', 'petani'),
                region=data.get('region'),
                dob=date.fromisoformat(data.get('dob', '2000-01-01')),
                gender=data.get('gender', 'L')
            )
            
            db.session.add(new_user)
            db.session.commit()
            
            return jsonify({'message': 'User created successfully', 'user_id': new_user.id})
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/users/<int:user_id>', methods=['PUT'])
    def api_admin_update_user(user_id):
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User
        try:
            user = User.query.get_or_404(user_id)
            data = request.get_json()
            
            # Update user fields
            if 'name' in data:
                user.name = data['name']
            if 'email' in data:
                # Check if email is already taken by another user
                existing_user = User.query.filter(User.email == data['email'], User.id != user_id).first()
                if existing_user:
                    return jsonify({'error': 'Email already taken by another user'}), 400
                user.email = data['email']
            if 'phone' in data:
                user.phone = data['phone']
            if 'role' in data:
                user.role = data['role']
            if 'region' in data:
                user.region = data['region']
            
            db.session.commit()
            return jsonify({'message': 'User updated successfully'})
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/users/<int:user_id>', methods=['DELETE'])
    def api_admin_delete_user(user_id):
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User
        try:
            user = User.query.get_or_404(user_id)
            
            # Don't allow deletion of the current admin user
            if user.id == session['user_id']:
                return jsonify({'error': 'Cannot delete your own account'}), 400
            
            db.session.delete(user)
            db.session.commit()
            return jsonify({'message': 'User deleted successfully'})
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/user-stats', methods=['GET'])
    def api_admin_user_stats():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User, ChatHistory
        from datetime import datetime, timedelta
        
        try:
            # Total users
            total_users = User.query.count()
            
            # Admin users
            admin_users = User.query.filter_by(role='admin').count()
            
            # New users in last 30 days
            thirty_days_ago = datetime.now() - timedelta(days=30)
            new_users = User.query.filter(User.created_at >= thirty_days_ago).count()
            
            # Active users (users who have chat history in last 7 days)
            seven_days_ago = datetime.now() - timedelta(days=7)
            active_users = User.query.join(ChatHistory).filter(
                ChatHistory.created_at >= seven_days_ago
            ).distinct().count()
            
            return jsonify({
                'total_users': total_users,
                'admin_users': admin_users,
                'new_users': new_users,
                'active_users': active_users
            })
        except Exception as e:
            return jsonify({'error': str(e)}), 500



    @app.route('/api/admin/logs', methods=['GET'])
    def api_admin_logs():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import ChatHistory, User
        from datetime import datetime, timedelta
        
        try:
            log_type = request.args.get('type', '')
            days = int(request.args.get('days', 7))
            
            cutoff_date = datetime.now() - timedelta(days=days)
            
            # Generate system logs based on available data
            logs = []
            
            # Chat logs
            if not log_type or log_type == 'chat':
                chats = ChatHistory.query.filter(
                    ChatHistory.created_at >= cutoff_date
                ).order_by(ChatHistory.created_at.desc()).limit(50).all()
                
                for chat in chats:
                    logs.append({
                        'message': f'User {chat.user.name if chat.user else "Unknown"} asked: {chat.question[:100]}...',
                        'timestamp': chat.created_at.isoformat(),
                        'type': 'chat'
                    })
            
            # Login logs (simulated based on first chat per day per user)
            if not log_type or log_type == 'login':
                from sqlalchemy import func
                daily_first_chats = db.session.query(
                    ChatHistory.user_id,
                    func.date(ChatHistory.created_at).label('chat_date'),
                    func.min(ChatHistory.created_at).label('first_chat')
                ).filter(
                    ChatHistory.created_at >= cutoff_date
                ).group_by(
                    ChatHistory.user_id, func.date(ChatHistory.created_at)
                ).all()
                
                for entry in daily_first_chats:
                    user = User.query.get(entry.user_id)
                    if user:
                        logs.append({
                            'message': f'User {user.name} logged in',
                            'timestamp': entry.first_chat.isoformat(),
                            'type': 'login'
                        })
            
            # Sort logs by timestamp
            logs.sort(key=lambda x: x['timestamp'], reverse=True)
            
            return jsonify({'logs': logs[:100]})  # Limit to 100 most recent
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/export-users', methods=['GET'])
    def api_admin_export_users():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User
        import csv
        from io import StringIO
        from flask import make_response
        
        try:
            output = StringIO()
            writer = csv.writer(output)
            
            # Write header
            writer.writerow(['ID', 'Name', 'Email', 'Phone', 'Role', 'Region', 'Created At'])
            
            # Write user data
            users = User.query.order_by(User.created_at.desc()).all()
            for user in users:
                writer.writerow([
                    user.id,
                    user.name,
                    user.email,
                    user.phone,
                    user.role,
                    user.region or '',
                    user.created_at.strftime('%Y-%m-%d %H:%M:%S')
                ])
            
            # Create response
            response = make_response(output.getvalue())
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = 'attachment; filename=users_export.csv'
            
            return response
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/recent-activity', methods=['GET'])
    def api_admin_recent_activity():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import User, ChatHistory
        from datetime import datetime, timedelta
        
        try:
            now = datetime.now()
            one_minute_ago = now - timedelta(minutes=1)
            one_hour_ago = now - timedelta(hours=1)
            
            # Check for new users in last minute
            new_users = User.query.filter(User.created_at >= one_minute_ago).count()
            
            # Check for new chats in last minute  
            new_chats = ChatHistory.query.filter(ChatHistory.created_at >= one_minute_ago).count()
            
            # Simulate error count (you can implement actual error tracking)
            errors = 0
            
            return jsonify({
                'new_users': new_users,
                'new_chats': new_chats,
                'errors': errors,
                'timestamp': now.isoformat()
            })
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    @app.route('/api/admin/provincial-topics', methods=['GET'])
    def api_admin_provincial_topics():
        if 'user_id' not in session or session.get('user_role') != 'admin':
            return jsonify({'error': 'Unauthorized'}), 401
        
        from .models import ChatHistory, User, Regency, Province
        from .topic_modeling import find_topic_clusters
        from collections import Counter
        from datetime import datetime, timedelta
        import re
        
        try:
            province_id = request.args.get('province_id')
            if not province_id:
                return jsonify({'error': 'Province ID is required'}), 400
            
            # Get province info
            province = Province.query.get(province_id)
            if not province:
                return jsonify({'error': 'Province not found'}), 404
            
            # Get all regencies in this province
            regencies = Regency.query.filter_by(province_id=province_id).all()
            regency_names = [r.name.replace('KABUPATEN ', '').replace('KOTA ', '') for r in regencies]
            
            # Get users from this province (match regency names with user regions)
            users_in_province = []
            if regency_names:
                conditions = [User.region.ilike(f'%{name}%') for name in regency_names]
                users_in_province = User.query.filter(db.or_(*conditions)).all()
            
            if not users_in_province:
                return jsonify({
                    'topics': [],
                    'total_questions': 0,
                    'province_name': province.name
                })
            
            user_ids = [u.id for u in users_in_province]
            
            # Get chat history for users in this province (last 30 days)
            thirty_days_ago = datetime.now() - timedelta(days=30)
            chats = ChatHistory.query.filter(
                ChatHistory.user_id.in_(user_ids),
                ChatHistory.created_at >= thirty_days_ago
            ).all()
            
            if not chats:
                return jsonify({
                    'topics': [],
                    'total_questions': 0,
                    'province_name': province.name
                })
            
            # Enhanced topic extraction
            questions = [chat.question for chat in chats]
            
            # Improved keyword-based topic extraction
            def extract_meaningful_topics(questions):
                # Agricultural keywords and phrases
                agricultural_keywords = {
                    'Tanaman Padi': ['padi', 'beras', 'sawah', 'gabah', 'varietas padi'],
                    'Tanaman Jagung': ['jagung', 'varietas jagung', 'benih jagung'],
                    'Tanaman Kedelai': ['kedelai', 'varietas kedelai', 'benih kedelai'],
                    'Tanaman Hortikultura': ['tomat', 'cabai', 'wortel', 'kangkung', 'bayam', 'selada', 'timun'],
                    'Tanaman Perkebunan': ['kelapa sawit', 'kopi', 'teh', 'kakao', 'karet', 'nilam', 'lada'],
                    'Pupuk dan Nutrisi': ['pupuk', 'kompos', 'pupuk organik', 'pupuk kimia', 'nutrisi', 'unsur hara'],
                    'Hama dan Penyakit': ['hama', 'penyakit', 'pestisida', 'fungisida', 'wereng', 'kutu', 'virus'],
                    'Teknik Budidaya': ['menanam', 'tanam', 'budidaya', 'kultur', 'pembibitan', 'persemaian'],
                    'Pengairan': ['irigasi', 'pengairan', 'air', 'drainase', 'pompa'],
                    'Pascapanen': ['panen', 'pengeringan', 'penyimpanan', 'pengolahan', 'pascapanen'],
                    'Permodalan': ['kredit', 'modal', 'subsidi', 'bantuan', 'pinjaman'],
                    'Teknologi Pertanian': ['teknologi', 'alat', 'mesin', 'traktor', 'drone'],
                    'Cuaca dan Iklim': ['cuaca', 'iklim', 'musim', 'hujan', 'kering', 'kemarau'],
                    'Pemasaran': ['jual', 'harga', 'pasar', 'pemasaran', 'distribusi']
                }
                
                topic_counts = {}
                question_matches = {}
                
                for question in questions:
                    question_lower = question.lower()
                    matched = False
                    
                    for topic, keywords in agricultural_keywords.items():
                        for keyword in keywords:
                            if keyword in question_lower:
                                if topic not in topic_counts:
                                    topic_counts[topic] = 0
                                    question_matches[topic] = []
                                topic_counts[topic] += 1
                                question_matches[topic].append(question)
                                matched = True
                                break
                        if matched:
                            break
                    
                    # If no agricultural topic matched, try to extract general farming terms
                    if not matched:
                        # Extract meaningful words (not stopwords)
                        words = re.findall(r'\b\w{4,}\b', question_lower)
                        farming_words = []
                        
                        stopwords = ['yang', 'dengan', 'untuk', 'dari', 'pada', 'dalam', 'akan', 
                                   'sudah', 'bisa', 'tidak', 'apakah', 'bagaimana', 'kenapa', 
                                   'dimana', 'kapan', 'siapa', 'agar', 'supaya', 'karena',
                                   'saya', 'kami', 'kita', 'mereka', 'anda', 'beliau',
                                   'ini', 'itu', 'tersebut', 'berikut', 'seperti']
                        
                        for word in words:
                            if word not in stopwords and len(word) > 3:
                                farming_words.append(word.title())
                        
                        if farming_words:
                            general_topic = f"Pertanyaan Umum ({', '.join(farming_words[:2])})"
                            if general_topic not in topic_counts:
                                topic_counts[general_topic] = 0
                            topic_counts[general_topic] += 1
                
                # Convert to list format
                topics = [{'name': topic, 'count': count} for topic, count in topic_counts.items()]
                topics.sort(key=lambda x: x['count'], reverse=True)
                
                return topics[:10]  # Return top 10 topics
            
            topics = extract_meaningful_topics(questions)
            
            return jsonify({
                'topics': topics,
                'total_questions': len(chats),
                'province_name': province.name
            })
            
        except Exception as e:
            print(f"Error in provincial topics: {e}")
            import traceback
            traceback.print_exc()
            return jsonify({'error': str(e)}), 500

    # Helper function for region coordinates (auto-detection prioritized)
    def get_region_coordinates(region_name):
        """Get coordinates for any region using fully automatic geocoding"""
        import requests
        import time
        import sys
        import os
        
        # Add current directory to path for auto_geocoding import
        sys.path.append(os.path.dirname(os.path.abspath(__file__ + '/..')))
        
        try:
            # Try to use the advanced auto-geocoding system
            from auto_geocoding import get_coordinates_auto
            coords = get_coordinates_auto(region_name)
            print(f"DEBUG: Auto-geocoded {region_name}: {coords}")
            return coords
            
        except ImportError:
            print(f"DEBUG: Auto-geocoding module not available, using simple automatic system")
            
            # Simple automatic geocoding fallback
            # Cache for performance
            if not hasattr(get_region_coordinates, 'cache'):
                get_region_coordinates.cache = {}
            
            cache_key = region_name.lower().strip()
            if cache_key in get_region_coordinates.cache:
                return get_region_coordinates.cache[cache_key]
            
            # Try Nominatim API directly
            try:
                time.sleep(0.1)  # Rate limiting
                query = f"{region_name}, Indonesia"
                url = f"https://nominatim.openstreetmap.org/search"
                params = {
                    'q': query,
                    'format': 'json',
                    'limit': 1,
                    'countrycodes': 'id'
                }
                headers = {'User-Agent': 'Indonesian Agriculture Dashboard/1.0'}
                
                response = requests.get(url, params=params, headers=headers, timeout=10)
                
                if response.status_code == 200:
                    data = response.json()
                    if data:
                        lat, lon = float(data[0]['lat']), float(data[0]['lon'])
                        coords = (lat, lon)
                        get_region_coordinates.cache[cache_key] = coords
                        print(f"DEBUG: Automatically geocoded {region_name}: {coords}")
                        return coords
                        
            except Exception as e:
                print(f"DEBUG: Automatic geocoding failed for {region_name}: {e}")
            
            # Intelligent default based on region name patterns
            region_lower = region_name.lower()
            
            if any(x in region_lower for x in ['jakarta', 'dki']):
                coords = (-6.2088, 106.8456)  # Jakarta
            elif any(x in region_lower for x in ['aceh', 'banda aceh']):
                coords = (5.5577, 95.3222)   # Banda Aceh
            elif any(x in region_lower for x in ['jawa barat', 'jabar', 'bandung']):
                coords = (-6.9175, 107.6191)  # Bandung
            elif any(x in region_lower for x in ['jawa timur', 'jatim', 'surabaya']):
                coords = (-7.2575, 112.7521)  # Surabaya
            elif any(x in region_lower for x in ['jawa tengah', 'jateng', 'semarang']):
                coords = (-6.9666, 110.4167)  # Semarang
            elif any(x in region_lower for x in ['sumatra', 'medan']):
                coords = (3.5952, 98.6722)    # Medan
            elif any(x in region_lower for x in ['kalimantan', 'borneo']):
                coords = (-2.2118, 113.9213)  # Central Kalimantan
            elif any(x in region_lower for x in ['sulawesi', 'makassar']):
                coords = (-5.1477, 119.4327)  # Makassar
            elif any(x in region_lower for x in ['papua', 'jayapura']):
                coords = (-2.5317, 140.7189)  # Jayapura
            elif any(x in region_lower for x in ['bali', 'denpasar']):
                coords = (-8.6500, 115.2167)  # Denpasar
            else:
                coords = (-2.5, 117.0)  # Geographic center of Indonesia
            
            get_region_coordinates.cache[cache_key] = coords
            print(f"DEBUG: Using intelligent default for {region_name}: {coords}")
            return coords

