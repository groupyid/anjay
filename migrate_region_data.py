#!/usr/bin/env python3
"""
Data Migration Script: Convert region text to province_id and regency_id

This script analyzes existing User.region text data and maps it to proper
province_id and regency_id foreign keys for normalized data structure.
"""

from app import app
from routes.models import db, User, Province, Regency
import re

def normalize_region_name(region_name):
    """Normalize region name for better matching"""
    if not region_name:
        return ""
    
    # Convert to lowercase and strip
    normalized = region_name.lower().strip()
    
    # Remove common prefixes
    normalized = re.sub(r'^(kabupaten|kab\.?|kota|kot\.?)\s+', '', normalized)
    
    # Handle Jakarta variations
    jakarta_variations = {
        'jakarta': 'dki jakarta',
        'dki': 'dki jakarta', 
        'jakarta pusat': 'dki jakarta',
        'jakarta utara': 'dki jakarta',
        'jakarta selatan': 'dki jakarta',
        'jakarta timur': 'dki jakarta',
        'jakarta barat': 'dki jakarta',
        'kepulauan seribu': 'dki jakarta'
    }
    
    if normalized in jakarta_variations:
        normalized = jakarta_variations[normalized]
    
    return normalized

def find_matching_province(region_text):
    """Find matching province for region text"""
    normalized_region = normalize_region_name(region_text)
    
    # Get all provinces
    provinces = Province.query.all()
    
    # Direct match first
    for province in provinces:
        province_normalized = normalize_region_name(province.name)
        if normalized_region == province_normalized:
            return province
    
    # Partial match
    for province in provinces:
        province_normalized = normalize_region_name(province.name)
        if normalized_region in province_normalized or province_normalized in normalized_region:
            return province
    
    return None

def find_matching_regency(region_text, province_id=None):
    """Find matching regency for region text"""
    normalized_region = normalize_region_name(region_text)
    
    # Build query
    query = Regency.query
    if province_id:
        query = query.filter(Regency.province_id == province_id)
    
    regencies = query.all()
    
    # Direct match first
    for regency in regencies:
        regency_normalized = normalize_region_name(regency.name)
        if normalized_region == regency_normalized:
            return regency
    
    # Partial match
    for regency in regencies:
        regency_normalized = normalize_region_name(regency.name)
        if normalized_region in regency_normalized or regency_normalized in normalized_region:
            return regency
    
    return None

def migrate_user_regions():
    """Migrate all user region data to province_id and regency_id"""
    
    print("🚀 Starting region data migration...")
    
    # Get all users with region data
    users = User.query.filter(User.region.isnot(None), User.region != '').all()
    print(f"📊 Found {len(users)} users with region data")
    
    migration_stats = {
        'total': len(users),
        'province_mapped': 0,
        'regency_mapped': 0,
        'no_match': 0,
        'errors': 0
    }
    
    for i, user in enumerate(users):
        try:
            print(f"\n📍 Processing user {i+1}/{len(users)}: {user.name} - Region: '{user.region}'")
            
            # Find matching province
            province = find_matching_province(user.region)
            if province:
                user.province_id = province.id
                migration_stats['province_mapped'] += 1
                print(f"  ✅ Mapped to province: {province.name} (ID: {province.id})")
                
                # Find matching regency within this province
                regency = find_matching_regency(user.region, province.id)
                if regency:
                    user.regency_id = regency.id
                    migration_stats['regency_mapped'] += 1
                    print(f"  ✅ Mapped to regency: {regency.name} (ID: {regency.id})")
                else:
                    print(f"  ⚠️  No matching regency found in {province.name}")
            else:
                migration_stats['no_match'] += 1
                print(f"  ❌ No matching province found for '{user.region}'")
            
        except Exception as e:
            migration_stats['errors'] += 1
            print(f"  🚨 Error processing user {user.id}: {e}")
    
    # Commit changes
    try:
        db.session.commit()
        print(f"\n✅ Migration completed successfully!")
    except Exception as e:
        db.session.rollback()
        print(f"\n🚨 Error committing changes: {e}")
        return False
    
    # Print statistics
    print(f"\n📊 Migration Statistics:")
    print(f"  Total users processed: {migration_stats['total']}")
    print(f"  Province mapped: {migration_stats['province_mapped']}")
    print(f"  Regency mapped: {migration_stats['regency_mapped']}")
    print(f"  No match found: {migration_stats['no_match']}")
    print(f"  Errors: {migration_stats['errors']}")
    
    return True

if __name__ == '__main__':
    with app.app_context():
        # Show sample data before migration
        print("🔍 Sample data before migration:")
        sample_users = User.query.filter(User.region.isnot(None)).limit(5).all()
        for user in sample_users:
            print(f"  User: {user.name} - Region: '{user.region}' - Province ID: {user.province_id} - Regency ID: {user.regency_id}")
        
        # Run migration
        success = migrate_user_regions()
        
        if success:
            print("\n🔍 Sample data after migration:")
            sample_users = User.query.filter(User.region.isnot(None)).limit(5).all()
            for user in sample_users:
                province_name = user.province.name if user.province else "None"
                regency_name = user.regency.name if user.regency else "None"
                print(f"  User: {user.name} - Region: '{user.region}' - Province: {province_name} ({user.province_id}) - Regency: {regency_name} ({user.regency_id})")
        
        print("\n🎉 Data migration script completed!")