UNDER CONSTRUCTION
    Though functional, this software is still in the process of being
    documented and should, therefore, be considered a work in progress.

NAME
    WebService::Shippo - Shippo API Client

VERSION
    version 0.0.18

SYNOPIS
    Note: though scripts and modules must always "use WebService::Shippo;"
    to import the client software, the "WebService::" portion of that
    package namespace may be dropped when subsequently referring to the main
    package or any of its resource classes. For example,
    "WebService::Shippo::Address" and "Shippo::Address" refer to the same
    class.

    To compel the developer to continue using the "WebService::" prefix does
    seem like an unreasonable form of torture, besides which, it probably
    doesn't leave much scope for indenting code as some class names would be
    very long. Use it, or don't use it. It's entirely up to you.

        use strict;
        use LWP::UserAgent;
        use WebService::Shippo;
    
        # If you aren't using a config file or the environment (SHIPPO_TOKEN=...)
        # to supply your API key, you can do so here:
    
        Shippo->api_key('PASTE YOUR AUTH TOKEN HERE')
            unless Shippo->api_key;
    
        # Complete example illustrating the the process of Shipment creation
        # through to label generation.
        #
        # Create a Shipment object:
    
        my $shipment = Shippo::Shipment->create(
            object_purpose => 'PURCHASE',
            address_from   => {
                object_purpose => 'PURCHASE',
                name           => 'Shawn Ippotle',
                company        => 'Shippo',
                street1        => '215 Clayton St.',
                city           => 'San Francisco',
                state          => 'CA',
                zip            => '94117',
                country        => 'US',
                phone          => '+1 555 341 9393',
                email          => 'shippotle@goshippo.com'
            },
            address_to => {
                object_purpose => 'PURCHASE',
                name           => 'Mr Hippo',
                company        => '',
                street1        => 'Broadway 1',
                street2        => '',
                city           => 'New York',
                state          => 'NY',
                zip            => '10007',
                country        => 'US',
                phone          => '+1 555 341 9393',
                email          => 'mrhippo@goshippo.com'
            },
            parcel => {
                length        => '5',
                width         => '5',
                height        => '5',
                distance_unit => 'in',
                weight        => '2',
                mass_unit     => 'lb'
            }
        );
    
        # Retrieve shipping rates and select preferred rate:
    
        my $rates = Shippo::Shipment->get_shipping_rates( $shipment->object_id );
        my $preferred_rate = $rates->item(2);
    
        # Purchase label at the preferred rate:
    
        my $transaction = Shippo::Transaction->create(
            rate            => $preferred_rate->object_id,
            label_file_type => 'PNG',
        );
    
        # Get the shipping label:
    
        my $label_url = Shippo::Transaction->get_shipping_label( $transaction->object_id );
        my $browser   = LWP::UserAgent->new;
        $browser->get( $transaction->label_url, ':content_file' => './sample.png' );
    
        # Print the transaction object...
    
        print "Transaction:\n", $transaction->to_json(1); # '1' makes the JSON readable

        --[content dumped to console]--
        Transaction:
        {
           "commercial_invoice_url" : null,
           "customs_note" : "",
           "label_url" : "https://shippo-delivery-east.s3.amazonaws.com/da2e68fe85f94a9ebca458d9f9d
        2446b.PNG?Signature=BjD2JMQt0ATd5jUWAKm%2B6FHcBPM%3D&Expires=1477323662&AWSAccessKeyId=AKIA
        JGLCC5MYLLWIG42A",
           "messages" : [],
           "metadata" : "",
           "notification_email_from" : false,
           "notification_email_other" : "",
           "notification_email_to" : false,
           "object_created" : "2015-10-25T15:41:01.182Z",
           "object_id" : "da2e68fe85f94a9ebca458d9f9d2446b",
           "object_owner" : "******@*********.***",
           "object_state" : "VALID",
           "object_status" : "SUCCESS",
           "object_updated" : "2015-10-25T15:41:02.494Z",
           "order" : null,
           "pickup_date" : null,
           "rate" : "3c76e81733d7417b9a801ce957f4219d",
           "submission_note" : "",
           "tracking_history" : [],
           "tracking_number" : "9499907123456123456781",
           "tracking_status" : {
              "object_created" : "2015-10-25T15:41:02.451Z",
              "object_id" : "02ce6dbd6d5a48cfb764fdeb0cb6e404",
              "object_updated" : "2015-10-25T15:41:02.451Z",
              "status" : "UNKNOWN",
              "status_date" : null,
              "status_details" : ""
           },
           "tracking_url_provider" : "https://tools.usps.com/go/TrackConfirmAction_input?origTrackN
        um=9499907123456123456781",
           "was_test" : true
        }
        --[end of content]--

    The sample code in this synopsis produced the following label (at a much
    larger size, of course), which was then saved as a PNG file using the
    "LWP::UserAgent" package:

    * <https://github.com/cpanic/WebService-Shippo/blob/master/sample.png>

DESCRIPTION
    Shippo connects you with multiple shipping providers (USPS, UPS and
    Fedex, for example) through one interface, offering you great discounts
    on a selection of shipping rates. You can sign-up for an account at
    <https://goshippo.com/>.

    The Shippo API can be used to automate and customize shipping
    capabilities for your e-commerce store or marketplace, enabling you to
    retrieve shipping rates, create and purchase shipping labels, track
    packages, and much more.

    Though Shippo *do* offer official API clients for a bevy of major
    languages, the venerable Perl 5 was not included in that list. This
    community offering attempts to correct that omission ;-)

  API Resources
    Access to all Shippo API resources is via URLs relative to the same
    encrypted API endpoint (https://api.goshippo.com/v1/).

    There are resource item classes to help with the nitty-gritty of
    interacting each type of resource:

    * Addresses

    * Parcels

    * Shipments

    * Rates

    * Transactions

    * Customs Items

    * Customs Declarations

    * Refunds

    * Manifests

    * Carrier Accounts

    Each item class has a related collection class with a similar name *in
    the plural form*. The rationale behind this is that the Shippo API can
    be used to retrieve single objects with the "fetch" method, and
    collections of objects with the "all" method, and different behaviours
    may be applied to collections, which is why both forms exist.

  Request & Response Data
    The Perl client ensures that requests are properly encoded and passed to
    the correct API endpoints using appropriate HTTP methods. There is
    documentation for each API resource, containing more details on the
    values accepted by and returned for a given resource (see "FULL API
    DOCUMENTATION").

    All API requests return responses encoded as JSON strings, which the
    client converts into Perl blessed object references of the correct type.
    As a rule, any resource attribute documented in the API specification
    will have an accessor of the same same in a Perl instance of that
    object.

  REST & Disposable Objects
    The Shippo API is built with simplicity and RESTful principles in mind:
    POST requests are used to create objects, GET requests to fetch and list
    objects, and PUT requests to update objects. The Perl client provides
    "create", "fetch", "all" and "update" methods for use with resource
    objects that permit such operations.

    Addresses, Parcels, Shipments, Rates, Transactions, Refunds, Customs
    Items and Customs Declarations are disposable objects. This means that
    once you create an object, you cannot change it. Instead, create a new
    one with the desired values. Carrier Accounts are the exception and may
    be updated via PUT requests.

METHODS
  api_key
    Get or set the key used by API requests for Shippo's token-based
    authentication. This is Shippo's preferred method of authentication.

    * Return the token currently being used for authentication.

          my $api_key = Shippo->api_key;

    * Set the token to be used for authentication.

          Shippo->api_key($auth_token);

      The "api_key" method is chainable when used as a setter.

  api_credentials
    Get or set the login credentials used by API requests for Shippo's
    legacy authentication. Legacy authentication means encoding the HTTP
    Authorization header for Basic Authentication so, even though requests
    and repsonses are encrypted, you should still consider using the
    token-based authentication instead (see "api_key").

    * Return the login credentials currently being used for authentication.

          my ($username, $password) = Shippo->api_credentials;

    * Set the credentials to be used for authentication.

          Shippo->api_credentials($username, $password);

      The "api_credentials" method is chainable when used as a setter.

    Whenever a configuration specifies both token and login credentials, the
    client will always favour token-based authentication. If "api_key" and
    "api_credentials" are both set manually then it is the most recently set
    mechanism that defines the HTTP Authorization header.

  pretty
    Get or set the state of the attribute influencing the default
    readability of objects serialized as JSON using the "to_json" method or
    automatic stringification.

    * Return the current state of the "pretty" attribute.

          my $boolean = Shippo->pretty;

    * Set the state of the "pretty" attribute.

          Shippo->pretty($boolean);

    Note: the "to_json" method also takes optional boolean argument that may
    be set to "true" or "false" to achieve the same effect for a single
    serialization, regardless of the default currently in force.

  response
        my $last_response = Shippo->response;

    Returns a copy of the "HTTP::Response" resulting from the most recent
    request.

EXPORTS
    The "WebService::Shippo" package exports a number of helpful subroutines
    by default:

  true
        my $fedex_account = Shippo::CarrierAccount->create(
            carrier    => 'fedex',
            account_id => '<YOUR-FEDEX-ACCOUNT-NUMBER>',
            parameters => { meter => '<YOUR-FEDEX-METER-NUMBER>' },
            test       => true,
            active     => true
        );

    Returns a scalar value which will evaluate to true.

    Since the *lingua franca* connecting Shippo's API and the Perl client is
    JSON, it can feel more natural to think in those terms. Thus, "true" may
    be used in place of 1. Now, when creating a new object from a JSON
    example, any literal and accidental use of "true" or "false" is much
    less likely to result in misery.

    See Ingy's boolean package for more guidance.

  false
        my $fedex_account = Shippo::CarrierAccount->create(
            carrier    => 'fedex',
            account_id => '<YOUR-FEDEX-ACCOUNT-NUMBER>',
            parameters => { meter => '<YOUR-FEDEX-METER-NUMBER>' },
            test       => false,
            active     => false
        );

    Returns a scalar value which will evaluate to false.

    Since the *lingua franca* connecting Shippo's API and the Perl client is
    JSON, it can feel more natural to think in those terms. Thus, "false"
    may be used in place of 0. Now, when creating a new object from a JSON
    example, any literal and accidental use of "true" or "false" is much
    less likely to result in misery.

    See Ingy's boolean package for more guidance.

  boolean
        my $bool = boolean($value);

    Casts a scalar value to a boolean value ("true" or "false").

    See Ingy's boolean package for more guidance.

  callback
        Shippo::CarrierAccounts->all(callback {
            $_->enable_test_mode;
        });

    Returns a blessed "sub" suitable for use as a callback. Some methods
    accept optional blocking callbacks in order to facilitate list
    transformations, so this package makes &Params::Callbacks::callback
    available for use.

    See Params::Callbacks for more guidance.

CONFIGURATION
    While the client does provide "api_key" and "api_credentials" methods to
    help with authentication, hard-coding such calls in anything more
    mission critical than a simple test script may *not* be the best way to
    go.

    As soon as it is imported, one of the first things the client does is
    search a number of locations for a YAML-encoded
    <https://en.wikipedia.org/wiki/YAML> configuration file. The first one
    it finds is loaded.

    In order, the locations searched are as follows:

    * "./.shipporc"

    * "/*path*/*to*/*home*/.shipporc"

    * "/*etc*/shipporc"

    * "/*path*/*to*/*perl*/*module*/*install*/*lib*/WebService/Shippo/Config
      .yml"

    The configuration file is very simple and needs to have the following
    structure, though not all elements are mandatory:

        ---
        username: martymcfly@pinheads.org
        password: yadayada
        private_token: f0e1d2c3b4a5968778695a4b3c2d1e0f96877869
        public_token: 96877869f0e1d2c3b4a5968778695a4b3c2d1e0f
        default_token: private_token

    At a minimum, your configuration should define values for
    "private_token" and "public_token". These are your Shippo Private and
    Publishable Auth tokens, which are found on your Shippo API page
    <https://goshippo.com/user/apikeys/>.

FULL API DOCUMENTATION
    * For API documentation, go to <https://goshippo.com/docs/>

    * For API support, contact <mailto:support@goshippo.com> with any
      questions.

SEE ALSO
  Shippo Objects
    * WebService::Shippo::Address

    * WebService::Shippo::Parcel

    * WebService::Shippo::Shipment

    * WebService::Shippo::Rate

    * WebService::Shippo::Transaction

    * WebService::Shippo::CustomsItem

    * WebService::Shippo::CustomsDeclaration

    * WebService::Shippo::Refund

    * WebService::Shippo::Manifest

    * WebService::Shippo::CarrierAccount

  Shippo Collections
    * WebService::Shippo::Addresses

    * WebService::Shippo::Parcels

    * WebService::Shippo::Shipments

    * WebService::Shippo::Rates

    * WebService::Shippo::Transactions

    * WebService::Shippo::CustomsItems

    * WebService::Shippo::CustomsDeclarations

    * WebService::Shippo::Refunds

    * WebService::Shippo::Manifests

    * WebService::Shippo::CarrierAccounts

REPOSITORY
    * <https://github.com/cpanic/WebService-Shippo>

    * <https://github.com/cpanic/WebService-Shippo/wiki>

AUTHOR
    Iain Campbell <cpanic@cpan.org>

COPYRIGHT AND LICENSE
    This software is copyright © 2015 by Iain Campbell.

    You may distribute this software under the terms of either the GNU
    General Public License or the Artistic License, as specified in the Perl
    README file.

