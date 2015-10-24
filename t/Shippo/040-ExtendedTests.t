use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../../lib";
use TestHarness;
use WebService::Shippo ':all';

my @tests = (
    testSetRateTimeout => sub {
        Shippo::Async->timeout( 0 );
        is( Shippo::Async->timeout, 0, __TEST__ );
        my $exception;
        my $shipment = Shippo::Shipment->create(
            object_purpose => 'PURCHASE',
            address_from   => Shippo::Address->create(
                'object_purpose' => 'PURCHASE',
                'name'           => 'Shawn Ippotle',
                'company'        => 'Shippo',
                'street1'        => '215 Clayton St.',
                'city'           => 'San Francisco',
                'state'          => 'CA',
                'zip'            => '94117',
                'country'        => 'US',
                'phone'          => '+1 555 341 9393',
                'email'          => 'shippotle@goshippo.com'
            ),
            address_to => Shippo::Address->create(
                'object_purpose' => 'PURCHASE',
                'name'           => 'Mr Hippo',
                'company'        => '',
                'street1'        => 'Broadway 1',
                'street2'        => '',
                'city'           => 'New York',
                'state'          => 'NY',
                'zip'            => '10007',
                'country'        => 'US',
                'phone'          => '+1 555 341 9393',
                'email'          => 'mrhippo@goshippo.com'
            ),
            parcel => Shippo::Parcel->create(
                'length'        => '5',
                'width'         => '5',
                'height'        => '5',
                'distance_unit' => 'in',
                'weight'        => '2',
                'mass_unit'     => 'lb',
            ),
        );
        is( $shipment->owner,     $shipment->{object_owner},   __TEST__ );
        is( $shipment->created,   $shipment->{object_created}, __TEST__ );
        is( $shipment->purpose,   $shipment->{object_purpose}, __TEST__ );
        is( $shipment->state,     $shipment->{object_state},   __TEST__ );
        is( $shipment->updated,   $shipment->{object_updated}, __TEST__ );
        is( $shipment->to_string, $shipment->to_json,          __TEST__ );
        my $rates;
        try {
            $rates = $shipment->get_shipping_rates( $shipment->id, 'GBP' );
        }
        catch {
            $exception = $_;
        };
        is( WebService::Shippo::Request->response->content,
            '{"count": 0, "next": null, "previous": null, "results": []}',
            __TEST__
        );
        like( $exception, qr/timed-out/i, __TEST__ );
        Shippo::Async->timeout( 60 );
        is( Shippo::Async->timeout, 60, __TEST__ );
        $rates = $shipment->get_shipping_rates( $shipment->id, 'GBP' );
        ok( $rates->results, __TEST__ );
    },
    testObject => sub {
        my $ca = WebService::Shippo::CarrierAccount->all_pages( results => 50 );
        my @ca = $ca->results;
        ok( @ca > 1, __TEST__ );
        my %p;
        for my $carrier ( $ca->items ) {
            %p = $carrier->parameters;
            if ( keys %p ) {
                last;
            }
        }
        ok( keys %p, __TEST__ );
        $ca->foo( 'foo' );
        is( $ca->foo, 'foo', __TEST__ );
    },
    testObjectList => sub {
        my $carrier_accounts
            = WebService::Shippo::CarrierAccount->all( results => 1 );
        is( $carrier_accounts->item_class, 'WebService::Shippo::CarrierAccount',
            __TEST__
        );
        my $items = $carrier_accounts->items;
        is_deeply( $items, [ $carrier_accounts->items ], __TEST__ );
        ok( $carrier_accounts->item_count, __TEST__ );
        for my $n ( 1 .. 3 ) {
            ok( $carrier_accounts->results, __TEST__ );
            last unless $carrier_accounts->{next};
            $carrier_accounts = $carrier_accounts->next_page;
        }
        $carrier_accounts = $carrier_accounts->plus_previous_pages;
        ok( @{ $carrier_accounts->{results} } > 1, __TEST__ );
        for my $n ( 1 .. 3 ) {
            ok( $carrier_accounts->results, __TEST__ );
            last unless $carrier_accounts->{next};
            $carrier_accounts = $carrier_accounts->next_page;
        }
        for my $n ( 1 .. 3 ) {
            ok( $carrier_accounts->results, __TEST__ );
            last unless $carrier_accounts->{previous};
            $carrier_accounts = $carrier_accounts->previous_page;
        }
        $carrier_accounts = $carrier_accounts->plus_previous_pages;
        ok( @{ $carrier_accounts->{results} } > 1, __TEST__ );
        $carrier_accounts
            = WebService::Shippo::CarrierAccount->all(
            results => @{ $carrier_accounts->{results} } || 1 );
        $carrier_accounts = $carrier_accounts->plus_next_pages;
        ok( @{ $carrier_accounts->{results} } > 1, __TEST__ );
        my $i = 0;
        my $p = 1;

        for ( 1 .. 10 ) {
            my $ii = $carrier_accounts->item_at_index( $i++ );
            my $ip = $carrier_accounts->item( $p++ );
            last unless $ii && $ip;
            is( $ip->id, $ii->id, __TEST__ );
        }
    },
    testpretty => sub {
        Shippo->pretty( 1 );
        is( Shippo->pretty, 1, __TEST__ );
        Shippo->pretty( 0 );
        is( Shippo->pretty, 0, __TEST__ );
    },
    testCurrency => [
        eur => sub {
            my $val = Shippo::Currency->validate_currency( 'EUR' );
            my @val = Shippo::Currency->validate_currency( 'EUR' );
            is( $val, 'EUR', __TEST__ );
            is_deeply( \@val, [ 'EUR', 'Euro' ], __TEST__ );
        },
        gbp => sub {
            my $val = Shippo::Currency->validate_currency( 'GBP' );
            my @val = Shippo::Currency->validate_currency( 'GBP' );
            is( $val, 'GBP', __TEST__ );
            is_deeply( \@val, [ 'GBP', 'Pound Sterling' ], __TEST__ );
        },
        usd => sub {
            my $val = Shippo::Currency->validate_currency( 'USD' );
            my @val = Shippo::Currency->validate_currency( 'USD' );
            is( $val, 'USD', __TEST__ );
            is_deeply( \@val, [ 'USD', 'US Dollar' ], __TEST__ );
        },
    ],
    testConfig => sub {
        my $config_file_before = WebService::Shippo::Config->config_file;
        WebService::Shippo::Config->config_file( '/etc/foo' );
        my $config_file_after = WebService::Shippo::Config->config_file;
        is( $config_file_after, '/etc/foo', __TEST__ );
        WebService::Shippo::Config->config_file( $config_file_before );
        my $config_before = WebService::Shippo::Config->config;
        WebService::Shippo::Config->config(
            {   foo           => 'bar',
                bar           => 'baz',
                private_token => 'bar',
                public_token  => 'foo'
            }
        );
        is(WebService::Shippo::Resource->api_private_token, 'bar', __TEST__);
        is(WebService::Shippo::Resource->api_public_token, 'foo', __TEST__);
        my $config_after = WebService::Shippo::Config->config;
        not_deeply( $config_before, $config_after, __TEST__ );
        WebService::Shippo::Config->reload_config;
        my $config_now = WebService::Shippo::Config->config;
        is_deeply( $config_now, $config_before, __TEST__ );
    },
);

SKIP: {
    skip '(no Shippo API key defined)', 1
        unless Shippo->api_key;
    TestHarness->run_tests( \@tests );
}

done_testing();
