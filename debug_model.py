#!/usr/bin/env python3
"""
Debug Model Import and Schema

Test direct model import and inspect what SQLAlchemy sees
"""

from app import app

def debug_model_import():
    """Debug model import and schema"""
    print("🔍 Debug Model Import")
    print("=" * 40)
    
    with app.app_context():
        try:
            # Import models
            from routes.models import db, User, Province, Regency
            print("✅ Models imported successfully")
            
            # Check User model attributes
            print(f"\n📊 User model attributes:")
            user_columns = [attr for attr in dir(User) if not attr.startswith('_')]
            for col in user_columns:
                if hasattr(User, col):
                    attr = getattr(User, col)
                    if hasattr(attr, 'property') and hasattr(attr.property, 'columns'):
                        print(f"  ✅ {col}: {attr.property.columns[0].type}")
            
            # Check if foreign key columns exist in model
            if hasattr(User, 'province_id'):
                print(f"✅ User.province_id exists: {User.province_id}")
            else:
                print("🚨 User.province_id NOT FOUND in model")
                
            if hasattr(User, 'regency_id'):
                print(f"✅ User.regency_id exists: {User.regency_id}")
            else:
                print("🚨 User.regency_id NOT FOUND in model")
            
            # Check actual database schema
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            
            print(f"\n📋 Database schema (user table):")
            db_columns = inspector.get_columns('user')
            for col in db_columns:
                print(f"  📊 {col['name']}: {col['type']}")
            
            # Check foreign keys
            foreign_keys = inspector.get_foreign_keys('user')
            print(f"\n🔗 Foreign keys in database:")
            if foreign_keys:
                for fk in foreign_keys:
                    print(f"  🔗 {fk['constrained_columns']} -> {fk['referred_table']}.{fk['referred_columns']}")
            else:
                print("  ⚠️  No foreign keys found in database")
            
            # Test model creation manually
            print(f"\n🏗️  Testing manual schema creation...")
            
            # Drop and recreate tables (CAREFUL!)
            print("⚠️  This will DROP existing tables!")
            response = input("Continue? (y/N): ")
            
            if response.lower() == 'y':
                db.drop_all()
                print("🗑️  Dropped all tables")
                
                db.create_all()
                print("🏗️  Created all tables")
                
                # Re-inspect
                inspector = inspect(db.engine)
                new_columns = [col['name'] for col in inspector.get_columns('user')]
                print(f"📊 New schema: {new_columns}")
                
                if 'province_id' in new_columns and 'regency_id' in new_columns:
                    print("🎉 SUCCESS! Foreign key columns now exist")
                else:
                    print("🚨 STILL MISSING foreign key columns")
            else:
                print("ℹ️  Skipped table recreation")
            
        except Exception as e:
            print(f"🚨 Debug failed: {e}")
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    debug_model_import()