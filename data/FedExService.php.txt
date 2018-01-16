<?php

namespace CommerceFedEx\FedExPHP\Services;

use \WsdlToPhp\PackageBase\AbstractSoapClientBase;

/**
 * Class FedExService
 * @package CommerceFedEx\FedExPHP\Services
 */
class FedExService extends AbstractSoapClientBase
{
  public $version;

  public function __construct(array $wsdlOptions = array(), $resetSoapClient = true, $mode = 'test') {
    if ($mode === false) $mode = 'test';
    if ($mode === true) $mode = 'live';
    parent::__construct($wsdlOptions,$resetSoapClient);
        if ($mode == 'live') $this->setLocation('https://ws.fedex.com:443/web-services');
        if ($mode == 'test') $this->setLocation('https://wsbeta.fedex.com:443/web-services');
  }

  public static function version() {
    $service = new static;
    return $service->version;
  }

}