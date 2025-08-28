<?php

namespace Config;

/**
 * Paths
 *
 * Holds the paths that are used by the system to
 * locate the main directories, app, system, etc.
 *
 * This is used by the bootstrap file and is the
 * central location for all path definitions.
 */
class Paths
{
    /**
     * The path to the application directory.
     */
    public $appDirectory = __DIR__ . '/../../app';

    /**
     * The path to the project root directory.
     */
    public $rootDirectory = __DIR__ . '/../..';

    /**
     * The path to the system directory.
     */
    public $systemDirectory = __DIR__ . '/../../vendor/codeigniter4/framework/system';

    /**
     * The path to the writable directory.
     */
    public $writableDirectory = __DIR__ . '/../../writable';

    /**
     * The path to the tests directory.
     */
    public $testsDirectory = __DIR__ . '/../../tests';

    /**
     * The path to the view directory.
     */
    public $viewDirectory = __DIR__ . '/../../app/Views';
}