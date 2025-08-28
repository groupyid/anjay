<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateCarsTable extends Migration
{
    public function up()
    {
        $this->forge->addField([
            'id' => [
                'type' => 'INT',
                'constraint' => 11,
                'unsigned' => true,
                'auto_increment' => true,
            ],
            'brand' => [
                'type' => 'VARCHAR',
                'constraint' => 50,
            ],
            'model' => [
                'type' => 'VARCHAR',
                'constraint' => 50,
            ],
            'year' => [
                'type' => 'INT',
                'constraint' => 4,
            ],
            'color' => [
                'type' => 'VARCHAR',
                'constraint' => 30,
            ],
            'license_plate' => [
                'type' => 'VARCHAR',
                'constraint' => 20,
            ],
            'daily_rate' => [
                'type' => 'DECIMAL',
                'constraint' => '10,2',
            ],
            'description' => [
                'type' => 'TEXT',
            ],
            'status' => [
                'type' => 'ENUM',
                'constraint' => ['available', 'rented', 'maintenance'],
                'default' => 'available',
            ],
            'created_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
            'updated_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
        ]);

        $this->forge->addKey('id', true);
        $this->forge->addUniqueKey('license_plate');
        $this->forge->createTable('cars');
    }

    public function down()
    {
        $this->forge->dropTable('cars');
    }
}