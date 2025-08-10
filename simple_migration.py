#!/usr/bin/env python3
"""
Simple Database Migration

Uses Flask-SQLAlchemy's built-in create_all() method to add new columns.
This is the safest approach for SQLAlchemy compatibility.
"""

from app import app
from routes.models import db, User, Province, Regency

def run_simple_migration():
    """Run migration using Flask-SQLAlchemy's create_all()"""
    print("🚀 Starting simple migration...")
    
    with app.app_context():
        try:
            # Check current columns
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            columns_before = [col['name'] for col in inspector.get_columns('user')]
            print(f"📊 Current columns: {columns_before}")
            
            # Create all tables (this will add new columns if they don't exist)
            print("🏗️  Running db.create_all()...")
            db.create_all()
            
            # Check columns after
            inspector = inspect(db.engine)
            columns_after = [col['name'] for col in inspector.get_columns('user')]
            new_columns = set(columns_after) - set(columns_before)
            
            if new_columns:
                print(f"✅ Added columns: {list(new_columns)}")
            else:
                print("ℹ️  No new columns added (already exist)")
            
            print(f"📊 Final columns: {columns_after}")
            
            # Verify foreign key columns exist
            if 'province_id' in columns_after and 'regency_id' in columns_after:
                print("✅ Foreign key columns confirmed present")
                return True
            else:
                print("🚨 Foreign key columns not found after migration")
                return False
                
        except Exception as e:
            print(f"🚨 Migration failed: {e}")
            return False

def test_relationships():
    """Test that relationships work correctly"""
    print("\n🔗 Testing model relationships...")
    
    with app.app_context():
        try:
            # Test basic queries
            total_provinces = Province.query.count()
            total_regencies = Regency.query.count()
            total_users = User.query.count()
            
            print(f"📊 Data counts:")
            print(f"  Provinces: {total_provinces}")
            print(f"  Regencies: {total_regencies}")
            print(f"  Users: {total_users}")
            
            # Test relationship access (should not error even if data is None)
            sample_user = User.query.first()
            if sample_user:
                province_name = sample_user.province.name if sample_user.province else "None"
                regency_name = sample_user.regency.name if sample_user.regency else "None"
                print(f"📋 Sample user relationships work:")
                print(f"  User: {sample_user.name}")
                print(f"  Province: {province_name}")
                print(f"  Regency: {regency_name}")
            
            print("✅ Relationship testing passed")
            return True
            
        except Exception as e:
            print(f"🚨 Relationship test failed: {e}")
            return False

if __name__ == '__main__':
    print("🏗️  Simple Database Migration")
    print("=" * 40)
    
    # Run migration
    migration_success = run_simple_migration()
    
    if migration_success:
        # Test relationships
        relationship_success = test_relationships()
        
        if relationship_success:
            print("\n🎉 MIGRATION SUCCESSFUL!")
            print("✅ Schema updated")
            print("✅ Relationships working")
            print("\n🎯 Next step: Run data migration")
            print("   python migrate_region_data.py")
        else:
            print("\n⚠️  Migration completed but relationships need review")
    else:
        print("\n🚨 Migration failed")
        
    print("=" * 40)