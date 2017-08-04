#!/bin/bash

FILES=wsdls/*.wsdl

rm -rf FedExPHP/src


for f in $FILES
do
    FILENAME=${f:6}
    SERVICE=${FILENAME%Service*.wsdl}
    echo "Processing $FILENAME Service $SERVICE"
    ./bin/wsdltophp.phar generate:package --config=config/wsdltophp.yml --urlorpath="wsdls/${FILENAME}" --destination="FedExPHP/" --namespace="NicholasCreativeMedia\FedExPHP" --force
  #  mv "FedExPHP/src/Services/Service.php" "FedExPHP/src/Services/${SERVICE}Service.php"
 #   mv "FedExPHP/src/ClassMap.php" "FedExPHP/src/${SERVICE}ClassMap.php"
    SRVID=`grep -A 1 "system or sub-system" FedExPHP/src/Structs/VersionId.php | tail -n 1 | sed 's/     \* - fixed: //'`
    MAJOR=`grep -A 1 "service business level" FedExPHP/src/Structs/VersionId.php | tail -n 1 | sed 's/     \* - fixed: //'`
    INT=`grep -A 1 "service interface level" FedExPHP/src/Structs/VersionId.php | tail -n 1 | sed 's/     \* - fixed: //'`
    MINOR=`grep -A 1 "service code level" FedExPHP/src/Structs/VersionId.php | tail -n 1 | sed 's/     \* - fixed: //'`
    #echo "Found Version $SRVID - $MAJOR - $INT - $MINOR";
    sed -i '' "s/class Service extends AbstractSoapClientBase/class ${SERVICE}Service extends FedExService/" "FedExPHP/src/Services/Service.php"
    sed "s/class ClassMap/class ${SERVICE}ClassMap/" <"FedExPHP/src/ClassMap.php" >"FedExPHP/src/${SERVICE}ClassMap.php"

    head -n 12 "FedExPHP/src/Services/Service.php" > "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "    /**" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "     * RateService constructor." >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "     * @param array \$wsdlOptions" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "     * @param bool \$resetSoapClient" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "     * @param bool \$beta" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "     */" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "    public function __construct(array \$wsdlOptions = array(), \$resetSoapClient = true, \$mode = 'test')" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "    {" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        if (\$mode === false) \$mode = 'test';" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        if (\$mode === true) \$mode = 'live';" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        \$default_options = [" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "           \WsdlToPhp\PackageBase\AbstractSoapClientBase::WSDL_URL => dirname(__FILE__).DIRECTORY_SEPARATOR.'wsdl-'.\$mode.DIRECTORY_SEPARATOR.'${FILENAME}'," >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "           \WsdlToPhp\PackageBase\AbstractSoapClientBase::WSDL_CLASSMAP => \\NicholasCreativeMedia\\FedExPHP\\${SERVICE}ClassMap::get()," >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        ];" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        \$options = array_merge(\$default_options,\$wsdlOptions);" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        parent::__construct(\$options,\$resetSoapClient,\$mode);" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "        \$this->version = new \\NicholasCreativeMedia\\FedExPHP\\Structs\\VersionId('${SRVID}',${MAJOR},${INT},${MINOR});" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo "    }" >> "FedExPHP/src/Services/${SERVICE}Service.php"
    echo ""

    tail -n +13 "FedExPHP/src/Services/Service.php" >> "FedExPHP/src/Services/${SERVICE}Service.php"


    rm "FedExPHP/src/Services/Service.php"
    rm "FedExPHP/src/ClassMap.php"

done

#cleanup
cp data/FedExService.php.txt FedExPHP/src/Services/FedExService.php
cp data/composer.json.txt FedExPHP/composer.json
cp data/LICENCE.txt FedExPHP/LICENCE.txt

mkdir FedExPHP/src/Services/wsdl-test
mkdir FedExPHP/src/Services/wsdl-live
cp wsdls/*.wsdl FedExPHP/src/Services/wsdl-test/

for f in $FILES
do
    FILENAME=${f:6}
    sed "s/wsbeta.fedex.com/ws.fedex.com/" < "wsdls/${FILENAME}" > "FedExPHP/src/Services/wsdl-live/${FILENAME}"
done

rm FedExPHP/tutorial.php
