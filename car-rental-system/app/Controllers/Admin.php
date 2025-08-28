<?php

namespace App\Controllers;

use App\Models\CarModel;
use App\Models\RentalModel;
use App\Models\UserModel;

class Admin extends BaseController
{
    protected $carModel;
    protected $rentalModel;
    protected $userModel;

    public function __construct()
    {
        $this->carModel = new CarModel();
        $this->rentalModel = new RentalModel();
        $this->userModel = new UserModel();
    }

    public function dashboard()
    {
        $data = [
            'total_cars' => $this->carModel->countAll(),
            'total_users' => $this->userModel->where('role', 'user')->countAllResults(),
            'total_rentals' => $this->rentalModel->countAll(),
            'pending_rentals' => $this->rentalModel->where('status', 'pending')->countAllResults(),
            'recent_rentals' => $this->rentalModel->getRecentRentals(5)
        ];
        return view('admin/dashboard', $data);
    }

    public function cars()
    {
        $data['cars'] = $this->carModel->findAll();
        return view('admin/cars', $data);
    }

    public function createCar()
    {
        if ($this->request->getMethod() === 'get') {
            return view('admin/create_car');
        }

        $rules = [
            'brand' => 'required',
            'model' => 'required',
            'year' => 'required|numeric',
            'color' => 'required',
            'license_plate' => 'required|is_unique[cars.license_plate]',
            'daily_rate' => 'required|numeric',
            'description' => 'required'
        ];

        if (!$this->validate($rules)) {
            return view('admin/create_car', ['validation' => $this->validator]);
        }

        $data = [
            'brand' => $this->request->getPost('brand'),
            'model' => $this->request->getPost('model'),
            'year' => $this->request->getPost('year'),
            'color' => $this->request->getPost('color'),
            'license_plate' => $this->request->getPost('license_plate'),
            'daily_rate' => $this->request->getPost('daily_rate'),
            'description' => $this->request->getPost('description'),
            'status' => 'available',
            'created_at' => date('Y-m-d H:i:s')
        ];

        $this->carModel->insert($data);
        session()->setFlashdata('success', 'Mobil berhasil ditambahkan!');
        return redirect()->to('admin/cars');
    }

    public function editCar($id)
    {
        if ($this->request->getMethod() === 'get') {
            $data['car'] = $this->carModel->find($id);
            return view('admin/edit_car', $data);
        }

        $rules = [
            'brand' => 'required',
            'model' => 'required',
            'year' => 'required|numeric',
            'color' => 'required',
            'license_plate' => 'required',
            'daily_rate' => 'required|numeric',
            'description' => 'required'
        ];

        if (!$this->validate($rules)) {
            $data['car'] = $this->carModel->find($id);
            return view('admin/edit_car', ['validation' => $this->validator, 'car' => $data['car']]);
        }

        $data = [
            'brand' => $this->request->getPost('brand'),
            'model' => $this->request->getPost('model'),
            'year' => $this->request->getPost('year'),
            'color' => $this->request->getPost('color'),
            'license_plate' => $this->request->getPost('license_plate'),
            'daily_rate' => $this->request->getPost('daily_rate'),
            'description' => $this->request->getPost('description'),
            'updated_at' => date('Y-m-d H:i:s')
        ];

        $this->carModel->update($id, $data);
        session()->setFlashdata('success', 'Data mobil berhasil diupdate!');
        return redirect()->to('admin/cars');
    }

    public function deleteCar($id)
    {
        $this->carModel->delete($id);
        session()->setFlashdata('success', 'Mobil berhasil dihapus!');
        return redirect()->to('admin/cars');
    }

    public function rentals()
    {
        $data['rentals'] = $this->rentalModel->getAllRentalsWithDetails();
        return view('admin/rentals', $data);
    }

    public function approveRental($id)
    {
        $this->rentalModel->update($id, ['status' => 'approved']);
        session()->setFlashdata('success', 'Rental berhasil disetujui!');
        return redirect()->to('admin/rentals');
    }

    public function rejectRental($id)
    {
        $this->rentalModel->update($id, ['status' => 'rejected']);
        session()->setFlashdata('success', 'Rental berhasil ditolak!');
        return redirect()->to('admin/rentals');
    }

    public function users()
    {
        $data['users'] = $this->userModel->where('role', 'user')->findAll();
        return view('admin/users', $data);
    }

    public function reports()
    {
        $data['monthly_rentals'] = $this->rentalModel->getMonthlyRentals();
        $data['popular_cars'] = $this->carModel->getPopularCars();
        return view('admin/reports', $data);
    }
}