[![Language](https://img.shields.io/badge/perl-v5.8%20to%205.22-blue.svg)](https://img.shields.io/badge/perl-v5.8%20to%205.22-blue.svg) [![Build Status](https://travis-ci.org/cpanic/WebService-Shippo.svg?branch=master)](https://travis-ci.org/cpanic/WebService-Shippo) [![Coverage Status](https://coveralls.io/repos/cpanic/WebService-Shippo/badge.svg?branch=master&service=github)](https://coveralls.io/github/cpanic/WebService-Shippo?branch=master)

## Shippo Perl API Client

Shippo is a shipping API that connects you with multiple shipping 
providers (such as USPS, UPS, and Fedex) through one interface, and offers 
you great discounts on shipping rates.

Don't have an account? Sign up at https://goshippo.com/

### Requirements

Perl 5.8.8 minimum. 

Build tests have been conducted successfully on all later versions of Perl.

### Installation

The Shippo Perl API Client is distributed using CPAN and may be installed just like any other Perl module. If you have never installed a Perl module before then I recommend using `cpanminus` because it's super easy!

If you have never used `cpanminus` before then you can install this package by running one of the following commands:

```shell
sudo -s 'curl -L cpanmin.us | perl - WebService::Shippo'

# If you're developing under PerlBrew then you probably don't want
# to use sudo...

curl -L cpanmin.us | perl - WebService::Shippo
```

If you **have** used `cpanminus` before then one of the following commands will do the job:

```shell
sudo -s cpanm WebService::Shippo

# If you're developing under PerlBrew then you probably don't want
# to use sudo...

cpanm WebService::Shippo
```
### Dependencies

* `File::HomeDir`
* `JSON::XS`
* `LWP`
* `MRO::Compat`
* `Path::Class`
* `URI::Encode`
* `YAML::XS`

The Shippo Perl client depends on the seven modules listed above.

### Using the Shippo Perl API Client

```perl
use strict;
use WebService::Shippo;

# Following statement not necessary if SHIPPO_TOKEN is set in
# your process environment.
Shippo->api_key(PRIVATE-AUTH-TOKEN);

my $address1 = Shippo::Address->create({
    object_purpose => 'PURCHASE',
    name           => 'John Smith',
    street1        => '6512 Greene Rd.',
    street2        => '',
    company        => 'Initech',
    phone          => '+1 234 346 7333',
    city           => 'Woodridge',
    state          => 'IL',
    zip            => '60517',
    country        => 'US',
    email          => 'user@gmail.com',
    metadata       => 'Customer ID 123456'
});

print 'Success with Address 1 : ', $address

# All being well, you should see something like the following output:

Success with Address 1 : {
   "city" : "Woodridge",
   "company" : "Initech",
   "country" : "US",
   "email" : "user@gmail.com",
   "ip" : null,
   "is_residential" : null,
   "messages" : [],
   "metadata" : "Customer ID 123456",
   "name" : "John Smith",
   "object_created" : "2015-10-16T16:14:16.296Z",
   "object_id" : "475bb05d72b74a08a1d44b40ac85d635",
   "object_owner" : "******@*********.***",
   "object_purpose" : "PURCHASE",
   "object_source" : "FULLY_ENTERED",
   "object_state" : "VALID",
   "object_updated" : "2015-10-16T16:14:16.296Z",
   "phone" : "0012343467333",
   "state" : "IL",
   "street1" : "6512 Greene Rd.",
   "street2" : "",
   "street_no" : "",
   "zip" : "60517"
}
```

### Full API documentation

* For API documentation, go to https://goshippo.com/docs/ 
* For API support, contact support@goshippo.com with any questions.
