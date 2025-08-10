#!/usr/bin/env python3
"""
Force Migration - Add Foreign Key Columns

Directly execute SQL to add foreign key columns to existing database
"""

from app import app
from routes.models import db

def force_add_columns():
    """Force add foreign key columns using direct SQL"""
    print("🔨 Force Migration - Adding Foreign Key Columns")
    print("=" * 50)
    
    with app.app_context():
        try:
            # Check current schema
            from sqlalchemy import inspect, text
            inspector = inspect(db.engine)
            current_columns = [col['name'] for col in inspector.get_columns('user')]
            print(f"📊 Current columns: {current_columns}")
            
            # SQL commands to add columns
            sql_commands = []
            
            if 'province_id' not in current_columns:
                sql_commands.append('ALTER TABLE "user" ADD COLUMN province_id INTEGER')
                print("➕ Will add province_id column")
            else:
                print("ℹ️  province_id already exists")
            
            if 'regency_id' not in current_columns:
                sql_commands.append('ALTER TABLE "user" ADD COLUMN regency_id INTEGER')
                print("➕ Will add regency_id column")
            else:
                print("ℹ️  regency_id already exists")
            
            if not sql_commands:
                print("✅ All columns already exist!")
                return True
            
            print(f"\n🚀 Executing {len(sql_commands)} SQL commands...")
            
            # Execute SQL commands
            with db.engine.connect() as conn:
                for i, sql in enumerate(sql_commands, 1):
                    print(f"📝 {i}. {sql}")
                    try:
                        conn.execute(text(sql))
                        print(f"   ✅ Success")
                    except Exception as e:
                        print(f"   🚨 Failed: {e}")
                        return False
                
                # Commit all changes
                conn.commit()
                print("💾 All changes committed")
            
            # Verify columns were added
            inspector = inspect(db.engine)
            new_columns = [col['name'] for col in inspector.get_columns('user')]
            print(f"\n📊 Updated columns: {new_columns}")
            
            # Check if our target columns exist
            success = 'province_id' in new_columns and 'regency_id' in new_columns
            
            if success:
                print("🎉 SUCCESS! Foreign key columns added")
                
                # Try to add indexes (optional)
                try:
                    print("\n🔗 Adding indexes...")
                    with db.engine.connect() as conn:
                        conn.execute(text('CREATE INDEX IF NOT EXISTS ix_user_province_id ON "user" (province_id)'))
                        conn.execute(text('CREATE INDEX IF NOT EXISTS ix_user_regency_id ON "user" (regency_id)'))
                        conn.commit()
                    print("✅ Indexes added successfully")
                except Exception as e:
                    print(f"⚠️  Index creation failed (non-critical): {e}")
                
                return True
            else:
                print("🚨 FAILED! Columns not found after migration")
                return False
                
        except Exception as e:
            print(f"🚨 Force migration failed: {e}")
            import traceback
            traceback.print_exc()
            return False

def verify_migration():
    """Verify the migration worked correctly"""
    print("\n🔍 Verifying Migration")
    print("=" * 30)
    
    with app.app_context():
        try:
            from sqlalchemy import inspect
            inspector = inspect(db.engine)
            
            # Check columns
            columns = [col['name'] for col in inspector.get_columns('user')]
            print(f"📊 Final columns: {columns}")
            
            # Check if target columns exist
            has_province_id = 'province_id' in columns
            has_regency_id = 'regency_id' in columns
            
            print(f"✅ province_id: {'✓' if has_province_id else '✗'}")
            print(f"✅ regency_id: {'✓' if has_regency_id else '✗'}")
            
            if has_province_id and has_regency_id:
                print("🎯 Migration verification PASSED")
                return True
            else:
                print("🚨 Migration verification FAILED")
                return False
                
        except Exception as e:
            print(f"🚨 Verification failed: {e}")
            return False

if __name__ == '__main__':
    print("🔨 FORCE MIGRATION TOOL")
    print("=" * 50)
    print("⚠️  WARNING: This will directly modify your database")
    print("📊 Target: Add province_id and regency_id columns to user table")
    
    proceed = input("\n🤔 Proceed with force migration? (y/N): ")
    
    if proceed.lower() != 'y':
        print("❌ Cancelled by user")
        exit(0)
    
    # Run force migration
    success = force_add_columns()
    
    if success:
        # Verify migration
        verify_success = verify_migration()
        
        if verify_success:
            print("\n🎉 COMPLETE SUCCESS!")
            print("✅ Columns added")
            print("✅ Migration verified")
            print("✅ Ready for data migration")
            print("\n🎯 Next step:")
            print("   python migrate_region_data.py")
        else:
            print("\n⚠️  Migration completed but verification failed")
    else:
        print("\n🚨 Migration failed")
        
    print("=" * 50)