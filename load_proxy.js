var proxy, contracts;
proxy = require('flexible_proxy_client');
debugger;
contracts = [];
for (i=0; i< 100; i=i+1) {
    contracts.push({
        "created_at": "2014-10-21T09:30:45.217Z",
        "customer_company_id": "1",
        "customer_contact_id": "1",
        "daily_rate_currency": "GBP",
        "daily_rate_pennies": 10000,
        "duration": 2678400,
        "end_date": "2013-01-31T00:00:00.000Z",
        "fq_name": "My First Contract",
        "id": "544627c51fedb0383c0000" + i,
        "name": "My Contract No " + (i + 1),
        "owner_company_id": "1",
        "owner_id": "544627c51fedb0383c000092",
        "start_date": "2013-01-01T00:00:00.000Z",
        "status": "accepted",
        "supplier_company_id": "1",
        "updated_at": "2014-10-21T09:30:45.217Z",
        "value_currency": "GBP",
        "value_pennies": 100000,
        "notes": [

        ]
    });
}
proxy.define([
    proxy.stub('http://localhost:9000/api/v1/contracts.json').andReturn({json: {
        "contracts": contracts,
        "total": contracts.length,
        "success": true
    }}),
    proxy.stub('http://localhost:35729/livereload.js').andReturn({
        json: {}
    })
], function () {console.log("YEP")});