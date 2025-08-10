"""Add province_id and regency_id foreign keys to user table

Revision ID: add_user_location_fks
Revises: 
Create Date: 2025-01-11 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_user_location_fks'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    # Add new columns
    op.add_column('user', sa.Column('province_id', sa.Integer(), nullable=True))
    op.add_column('user', sa.Column('regency_id', sa.Integer(), nullable=True))
    
    # Create foreign key constraints
    op.create_foreign_key('fk_user_province', 'user', 'province', ['province_id'], ['id'])
    op.create_foreign_key('fk_user_regency', 'user', 'regency', ['regency_id'], ['id'])
    
    # Create indexes for better performance
    op.create_index('ix_user_province_id', 'user', ['province_id'])
    op.create_index('ix_user_regency_id', 'user', ['regency_id'])

def downgrade():
    # Drop indexes
    op.drop_index('ix_user_regency_id', 'user')
    op.drop_index('ix_user_province_id', 'user')
    
    # Drop foreign key constraints
    op.drop_constraint('fk_user_regency', 'user', type_='foreignkey')
    op.drop_constraint('fk_user_province', 'user', type_='foreignkey')
    
    # Drop columns
    op.drop_column('user', 'regency_id')
    op.drop_column('user', 'province_id')