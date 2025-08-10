#!/usr/bin/env python3
"""
Debug Data Mismatch

Investigate differences between database content and dashboard display
"""

from app import app
from routes.models import db, User, Province, Regency, ChatHistory

def debug_data_sources():
    """Debug all data sources that dashboard uses"""
    print("🔍 DEBUG DATA MISMATCH")
    print("=" * 50)
    
    with app.app_context():
        try:
            # 1. Check User table data
            print("📊 USER TABLE DATA:")
            users = User.query.all()
            for user in users:
                province_name = user.province.name if user.province else "None"
                regency_name = user.regency.name if user.regency else "None"
                print(f"  👤 {user.name}:")
                print(f"    Region (text): '{user.region}'")
                print(f"    Province ID: {user.province_id} -> {province_name}")
                print(f"    Regency ID: {user.regency_id} -> {regency_name}")
                print()
            
            # 2. Check Province table data
            print("🏛️  PROVINCE TABLE DATA:")
            provinces = Province.query.all()
            for province in provinces:
                user_count = User.query.filter_by(province_id=province.id).count()
                print(f"  🏛️  ID {province.id}: '{province.name}' - {user_count} users")
            
            # 3. Check Regency table data (sample)
            print("\n🏘️  REGENCY TABLE DATA (sample):")
            regencies = Regency.query.limit(20).all()
            for regency in regencies:
                user_count = User.query.filter_by(regency_id=regency.id).count()
                print(f"  🏘️  ID {regency.id}: '{regency.name}' (Province: {regency.province.name}) - {user_count} users")
            
            # 4. Check specific Bandung entries
            print("\n🔍 BANDUNG-RELATED DATA:")
            bandung_provinces = Province.query.filter(Province.name.ilike('%bandung%')).all()
            bandung_regencies = Regency.query.filter(Regency.name.ilike('%bandung%')).all()
            
            print("  📍 Provinces with 'bandung':")
            for p in bandung_provinces:
                print(f"    🏛️  {p.id}: '{p.name}'")
            
            print("  📍 Regencies with 'bandung':")
            for r in bandung_regencies:
                print(f"    🏘️  {r.id}: '{r.name}' (Province: {r.province.name})")
            
            # 5. Check users with Bandung region
            print("\n👥 USERS WITH BANDUNG IN REGION:")
            bandung_users = User.query.filter(User.region.ilike('%bandung%')).all()
            for user in bandung_users:
                print(f"  👤 {user.name}: region='{user.region}', province_id={user.province_id}, regency_id={user.regency_id}")
            
            # 6. Check ChatHistory for users with Bandung
            print("\n💬 CHAT HISTORY FOR BANDUNG USERS:")
            for user in bandung_users:
                chat_count = ChatHistory.query.filter_by(user_id=user.id).count()
                print(f"  👤 {user.name}: {chat_count} chat messages")
            
            # 7. Check what dashboard province dropdown shows
            print("\n📋 WHAT DASHBOARD SHOULD SHOW:")
            print("  Dashboard dropdown is populated from Province table:")
            for province in Province.query.order_by(Province.name).all():
                print(f"    Option: {province.id} - {province.name}")
            
        except Exception as e:
            print(f"🚨 Debug failed: {e}")
            import traceback
            traceback.print_exc()

def check_api_response():
    """Check what API endpoints return"""
    print("\n🌐 API RESPONSE SIMULATION:")
    print("=" * 30)
    
    with app.app_context():
        try:
            # Simulate what /api/admin/provinces returns
            from routes.routes import app as flask_app
            with flask_app.test_client() as client:
                print("📡 Testing /api/admin/provinces:")
                response = client.get('/api/admin/provinces')
                if response.status_code == 200:
                    import json
                    data = json.loads(response.data)
                    print(f"  Status: {response.status_code}")
                    print(f"  Data count: {len(data)}")
                    for item in data[:10]:  # Show first 10
                        print(f"    {item['id']}: {item['name']}")
                    if len(data) > 10:
                        print(f"    ... and {len(data) - 10} more")
                else:
                    print(f"  ❌ Failed: {response.status_code}")
            
        except Exception as e:
            print(f"🚨 API test failed: {e}")

if __name__ == '__main__':
    debug_data_sources()
    check_api_response()