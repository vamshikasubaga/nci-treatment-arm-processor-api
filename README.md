nci-treatment-arm-processor-api
=================================
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d72ed05402a54c3398ad1fec364b5661)](https://www.codacy.com/app/adithya-sampatoor/nci-treatment-arm-processor-api?utm_source=github.com&utm_medium=referral&utm_content=CBIIT/nci-treatment-arm-processor-api&utm_campaign=badger)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/e6a78261cdb54724a08ececc0c66e4ac)](https://www.codacy.com/app/FNLCR/nci-treatment-arm-processor-api?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=CBIIT/nci-treatment-arm-processor-api&amp;utm_campaign=Badge_Coverage)
[![Build Status](https://travis-ci.org/CBIIT/nci-treatment-arm-processor-api.svg?branch=master)](https://travis-ci.org/CBIIT/nci-treatment-arm-processor-api)

This repository contains the component that processes treatment arm messages in the treatment arm ecosystem.

* To start the server locally : `rails s`
* Server listens at port 10236
* To delete TreatmentArm & TreatmentArmAssignmentEvent tables, run `./data/delete_all_tables.sh`
* To list all the tables in DynamoDB, run `./data/list_tables.sh`
