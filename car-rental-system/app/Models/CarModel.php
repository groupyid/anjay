<?php

namespace App\Models;

use CodeIgniter\Model;

class CarModel extends Model
{
    protected $table = 'cars';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'brand', 'model', 'year', 'color', 'license_plate', 'daily_rate', 'description', 'status', 'created_at', 'updated_at'
    ];

    // Dates
    protected $useTimestamps = false;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    // Validation
    protected $validationRules = [
        'brand' => 'required|min_length[2]',
        'model' => 'required|min_length[2]',
        'year' => 'required|numeric|greater_than[1900]|less_than_equal_to[2024]',
        'color' => 'required|min_length[3]',
        'license_plate' => 'required|min_length[4]|is_unique[cars.license_plate,id,{id}]',
        'daily_rate' => 'required|numeric|greater_than[0]',
        'description' => 'required|min_length[10]',
        'status' => 'required|in_list[available,rented,maintenance]'
    ];

    protected $validationMessages = [
        'brand' => [
            'required' => 'Merek mobil harus diisi',
            'min_length' => 'Merek mobil minimal 2 karakter'
        ],
        'model' => [
            'required' => 'Model mobil harus diisi',
            'min_length' => 'Model mobil minimal 2 karakter'
        ],
        'year' => [
            'required' => 'Tahun mobil harus diisi',
            'numeric' => 'Tahun harus berupa angka',
            'greater_than' => 'Tahun mobil harus lebih dari 1900',
            'less_than_equal_to' => 'Tahun mobil tidak boleh lebih dari 2024'
        ],
        'color' => [
            'required' => 'Warna mobil harus diisi',
            'min_length' => 'Warna mobil minimal 3 karakter'
        ],
        'license_plate' => [
            'required' => 'Nomor plat mobil harus diisi',
            'min_length' => 'Nomor plat minimal 4 karakter',
            'is_unique' => 'Nomor plat sudah terdaftar'
        ],
        'daily_rate' => [
            'required' => 'Harga sewa per hari harus diisi',
            'numeric' => 'Harga harus berupa angka',
            'greater_than' => 'Harga harus lebih dari 0'
        ],
        'description' => [
            'required' => 'Deskripsi mobil harus diisi',
            'min_length' => 'Deskripsi minimal 10 karakter'
        ]
    ];

    protected $skipValidation = false;
    protected $cleanValidationRules = true;

    // Callbacks
    protected $allowCallbacks = true;
    protected $beforeInsert = [];
    protected $afterInsert = [];
    protected $beforeUpdate = [];
    protected $afterUpdate = [];
    protected $beforeFind = [];
    protected $afterFind = [];
    protected $beforeDelete = [];
    protected $afterDelete = [];

    /**
     * Get popular cars based on rental count
     */
    public function getPopularCars($limit = 5)
    {
        $db = \Config\Database::connect();
        $sql = "SELECT c.*, COUNT(r.id) as rental_count 
                FROM cars c 
                LEFT JOIN rentals r ON c.id = r.car_id 
                GROUP BY c.id 
                ORDER BY rental_count DESC 
                LIMIT ?";
        
        return $db->query($sql, [$limit])->getResultArray();
    }

    /**
     * Get available cars
     */
    public function getAvailableCars()
    {
        return $this->where('status', 'available')->findAll();
    }

    /**
     * Get cars by brand
     */
    public function getCarsByBrand($brand)
    {
        return $this->where('brand', $brand)->where('status', 'available')->findAll();
    }

    /**
     * Search cars
     */
    public function searchCars($keyword)
    {
        return $this->like('brand', $keyword)
                    ->orLike('model', $keyword)
                    ->orLike('color', $keyword)
                    ->where('status', 'available')
                    ->findAll();
    }
}