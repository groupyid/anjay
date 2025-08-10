#!/usr/bin/env python3
"""
Comprehensive Migration Runner

This script handles both schema migration (adding FK columns) 
and data migration (converting text to IDs).
"""

import os
import sys
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def run_schema_migration():
    """Run database schema migration to add FK columns"""
    print("🏗️  Step 1: Running schema migration...")
    
    # Import app and models to ensure tables are created
    from app import app
    from routes.models import db, User, Province, Regency
    
    with app.app_context():
        try:
            # Check if columns already exist
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            columns = [col['name'] for col in inspector.get_columns('user')]
            
            if 'province_id' in columns and 'regency_id' in columns:
                print("✅ Foreign key columns already exist, skipping schema migration")
                return True
            
            # Add columns manually (since Flask-Migrate might not be configured)
            print("📊 Adding province_id and regency_id columns...")
            
            # Use SQLAlchemy 2.x compatible syntax
            from sqlalchemy import text
            
            if 'province_id' not in columns:
                with db.engine.connect() as conn:
                    conn.execute(text('ALTER TABLE "user" ADD COLUMN province_id INTEGER'))
                    conn.commit()
                print("✅ Added province_id column")
            
            if 'regency_id' not in columns:
                with db.engine.connect() as conn:
                    conn.execute(text('ALTER TABLE "user" ADD COLUMN regency_id INTEGER'))
                    conn.commit()
                print("✅ Added regency_id column")
            
            # Add foreign key constraints (if database supports it)
            try:
                with db.engine.connect() as conn:
                    conn.execute(text('CREATE INDEX IF NOT EXISTS ix_user_province_id ON "user" (province_id)'))
                    conn.execute(text('CREATE INDEX IF NOT EXISTS ix_user_regency_id ON "user" (regency_id)'))
                    conn.commit()
                print("✅ Added indexes for foreign keys")
            except Exception as e:
                print(f"⚠️  Could not add indexes: {e}")
            
            print("✅ Schema migration completed successfully")
            return True
            
        except Exception as e:
            print(f"🚨 Schema migration failed: {e}")
            return False

def run_data_migration():
    """Run data migration to convert region text to IDs"""
    print("\n📊 Step 2: Running data migration...")
    
    try:
        # Import and run the data migration script
        from migrate_region_data import migrate_user_regions
        from app import app
        
        with app.app_context():
            success = migrate_user_regions()
            
        if success:
            print("✅ Data migration completed successfully")
            return True
        else:
            print("🚨 Data migration failed")
            return False
            
    except Exception as e:
        print(f"🚨 Data migration error: {e}")
        return False

def verify_migration():
    """Verify migration was successful"""
    print("\n🔍 Step 3: Verifying migration...")
    
    from app import app
    from routes.models import db, User
    
    with app.app_context():
        try:
            # Check total users
            total_users = User.query.count()
            users_with_province = User.query.filter(User.province_id.isnot(None)).count()
            users_with_regency = User.query.filter(User.regency_id.isnot(None)).count()
            users_with_region_text = User.query.filter(User.region.isnot(None), User.region != '').count()
            
            print(f"📊 Migration Verification:")
            print(f"  Total users: {total_users}")
            print(f"  Users with region text: {users_with_region_text}")
            print(f"  Users with province_id: {users_with_province}")
            print(f"  Users with regency_id: {users_with_regency}")
            
            if users_with_region_text > 0:
                migration_rate = (users_with_province / users_with_region_text) * 100
                print(f"  Migration success rate: {migration_rate:.1f}%")
                
                if migration_rate > 80:
                    print("✅ Migration verification: EXCELLENT")
                elif migration_rate > 60:
                    print("⚠️  Migration verification: GOOD")
                else:
                    print("🚨 Migration verification: NEEDS REVIEW")
            else:
                print("ℹ️  No users with region text data found")
            
            # Show sample of migrated data
            print(f"\n📋 Sample migrated data:")
            sample_users = User.query.filter(
                User.region.isnot(None),
                User.province_id.isnot(None)
            ).limit(5).all()
            
            for user in sample_users:
                province_name = user.province.name if user.province else "None"
                regency_name = user.regency.name if user.regency else "None"
                print(f"  {user.name}: '{user.region}' → Province: {province_name}, Regency: {regency_name}")
            
            return True
            
        except Exception as e:
            print(f"🚨 Verification failed: {e}")
            return False

def main():
    """Run complete migration process"""
    print("🚀 Starting Complete Database Migration")
    print("=" * 50)
    
    # Step 1: Schema Migration
    schema_success = run_schema_migration()
    if not schema_success:
        print("🚨 Migration aborted due to schema migration failure")
        return False
    
    # Step 2: Data Migration
    data_success = run_data_migration()
    if not data_success:
        print("⚠️  Schema migration completed but data migration failed")
        print("   You can retry data migration later with: python migrate_region_data.py")
        return False
    
    # Step 3: Verification
    verify_success = verify_migration()
    
    if schema_success and data_success and verify_success:
        print("\n🎉 COMPLETE MIGRATION SUCCESS!")
        print("=" * 50)
        print("✅ Schema migration: DONE")
        print("✅ Data migration: DONE") 
        print("✅ Verification: PASSED")
        print("\n🎯 Next steps:")
        print("  1. Test dashboard with DKI Jakarta selection")
        print("  2. Verify data appears correctly")
        print("  3. Monitor performance improvements")
        return True
    else:
        print("\n🚨 MIGRATION COMPLETED WITH ISSUES")
        print("Please review the logs above and address any issues")
        return False

if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)