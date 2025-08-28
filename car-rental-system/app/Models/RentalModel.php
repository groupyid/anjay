<?php

namespace App\Models;

use CodeIgniter\Model;

class RentalModel extends Model
{
    protected $table = 'rentals';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'user_id', 'car_id', 'start_date', 'end_date', 'total_days', 'total_amount', 'status', 'created_at', 'updated_at'
    ];

    // Dates
    protected $useTimestamps = false;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    // Validation
    protected $validationRules = [
        'user_id' => 'required|numeric',
        'car_id' => 'required|numeric',
        'start_date' => 'required|valid_date',
        'end_date' => 'required|valid_date',
        'total_days' => 'required|numeric|greater_than[0]',
        'total_amount' => 'required|numeric|greater_than[0]',
        'status' => 'required|in_list[pending,approved,rejected,completed,cancelled]'
    ];

    protected $validationMessages = [
        'user_id' => [
            'required' => 'User ID harus diisi',
            'numeric' => 'User ID harus berupa angka'
        ],
        'car_id' => [
            'required' => 'Car ID harus diisi',
            'numeric' => 'Car ID harus berupa angka'
        ],
        'start_date' => [
            'required' => 'Tanggal mulai harus diisi',
            'valid_date' => 'Format tanggal tidak valid'
        ],
        'end_date' => [
            'required' => 'Tanggal selesai harus diisi',
            'valid_date' => 'Format tanggal tidak valid'
        ],
        'total_days' => [
            'required' => 'Total hari harus diisi',
            'numeric' => 'Total hari harus berupa angka',
            'greater_than' => 'Total hari harus lebih dari 0'
        ],
        'total_amount' => [
            'required' => 'Total biaya harus diisi',
            'numeric' => 'Total biaya harus berupa angka',
            'greater_than' => 'Total biaya harus lebih dari 0'
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
     * Get all rentals with user and car details
     */
    public function getAllRentalsWithDetails()
    {
        $db = \Config\Database::connect();
        $sql = "SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
                       c.brand, c.model, c.license_plate, c.daily_rate
                FROM rentals r
                JOIN users u ON r.user_id = u.id
                JOIN cars c ON r.car_id = c.id
                ORDER BY r.created_at DESC";
        
        return $db->query($sql)->getResultArray();
    }

    /**
     * Get user rentals with car details
     */
    public function getUserRentalsWithDetails($userId)
    {
        $db = \Config\Database::connect();
        $sql = "SELECT r.*, c.brand, c.model, c.license_plate, c.daily_rate, c.color, c.year
                FROM rentals r
                JOIN cars c ON r.car_id = c.id
                WHERE r.user_id = ?
                ORDER BY r.created_at DESC";
        
        return $db->query($sql, [$userId])->getResultArray();
    }

    /**
     * Get recent rentals
     */
    public function getRecentRentals($limit = 5)
    {
        $db = \Config\Database::connect();
        $sql = "SELECT r.*, u.name as user_name, c.brand, c.model, c.license_plate
                FROM rentals r
                JOIN users u ON r.user_id = u.id
                JOIN cars c ON r.car_id = c.id
                ORDER BY r.created_at DESC
                LIMIT ?";
        
        return $db->query($sql, [$limit])->getResultArray();
    }

    /**
     * Get monthly rentals for reporting
     */
    public function getMonthlyRentals()
    {
        $db = \Config\Database::connect();
        $sql = "SELECT DATE_FORMAT(created_at, '%Y-%m') as month,
                       COUNT(*) as total_rentals,
                       SUM(total_amount) as total_revenue
                FROM rentals
                WHERE status = 'approved'
                GROUP BY DATE_FORMAT(created_at, '%Y-%m')
                ORDER BY month DESC
                LIMIT 12";
        
        return $db->query($sql)->getResultArray();
    }

    /**
     * Get rental statistics
     */
    public function getRentalStats()
    {
        $db = \Config\Database::connect();
        $sql = "SELECT 
                    COUNT(*) as total_rentals,
                    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_rentals,
                    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_rentals,
                    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_rentals,
                    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_rentals,
                    SUM(total_amount) as total_revenue
                FROM rentals";
        
        return $db->query($sql)->getRowArray();
    }

    /**
     * Check if car is available for rental
     */
    public function isCarAvailable($carId, $startDate, $endDate)
    {
        $db = \Config\Database::connect();
        $sql = "SELECT COUNT(*) as count
                FROM rentals
                WHERE car_id = ? 
                AND status IN ('pending', 'approved')
                AND (
                    (start_date BETWEEN ? AND ?) OR
                    (end_date BETWEEN ? AND ?) OR
                    (start_date <= ? AND end_date >= ?)
                )";
        
        $result = $db->query($sql, [$carId, $startDate, $endDate, $startDate, $endDate, $startDate, $endDate])->getRowArray();
        return $result['count'] == 0;
    }
}