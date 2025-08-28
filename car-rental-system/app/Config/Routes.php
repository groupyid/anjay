<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// Auth routes
$routes->get('/', 'Auth::index');
$routes->get('login', 'Auth::index');
$routes->post('login', 'Auth::login');
$routes->get('register', 'Auth::register');
$routes->post('register', 'Auth::register');
$routes->get('logout', 'Auth::logout');

// Admin routes
$routes->group('admin', ['filter' => 'auth:admin'], function($routes) {
    $routes->get('/', 'Admin::dashboard');
    $routes->get('dashboard', 'Admin::dashboard');
    $routes->get('cars', 'Admin::cars');
    $routes->get('cars/create', 'Admin::createCar');
    $routes->post('cars/create', 'Admin::createCar');
    $routes->get('cars/edit/(:num)', 'Admin::editCar/$1');
    $routes->post('cars/edit/(:num)', 'Admin::editCar/$1');
    $routes->get('cars/delete/(:num)', 'Admin::deleteCar/$1');
    $routes->get('rentals', 'Admin::rentals');
    $routes->get('rentals/approve/(:num)', 'Admin::approveRental/$1');
    $routes->get('rentals/reject/(:num)', 'Admin::rejectRental/$1');
    $routes->get('users', 'Admin::users');
    $routes->get('reports', 'Admin::reports');
});

// User routes
$routes->group('user', ['filter' => 'auth:user'], function($routes) {
    $routes->get('/', 'User::dashboard');
    $routes->get('dashboard', 'User::dashboard');
    $routes->get('cars', 'User::cars');
    $routes->get('cars/(:num)', 'User::carDetail/$1');
    $routes->post('rent', 'User::rentCar');
    $routes->get('my-rentals', 'User::myRentals');
    $routes->get('profile', 'User::profile');
    $routes->post('profile', 'User::updateProfile');
});

// Public routes
$routes->get('cars', 'Home::cars');
$routes->get('cars/(:num)', 'Home::carDetail/$1');
$routes->get('about', 'Home::about');
$routes->get('contact', 'Home::contact');