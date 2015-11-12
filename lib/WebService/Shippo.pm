use strict;
use warnings;

package WebService::Shippo;
# ABSTRACT: A Shippo Perl API wrapper
our $VERSION = '0.0.20';
require WebService::Shippo::Entities;
use boolean ':all';
use Params::Callbacks ( 'callbacks', 'callback' );
use base ( 'Exporter' );

our @EXPORT = qw(
    true
    false
    boolean
    callback
);

sub import
{
    my ( $class ) = @_;
    # Configure Shippo client on import
    WebService::Shippo::Config->config;
    # The API key is overridden with the environment's value if defined.
    WebService::Shippo::Resource->api_credentials(
        @ENV{ 'SHIPPO_USER', 'SHIPPO_PASS' } )
        if $ENV{SHIPPO_USER} && !$ENV{SHIPPO_TOKEN};
    WebService::Shippo::Resource->api_key( $ENV{SHIPPO_TOKEN} )
        if $ENV{SHIPPO_TOKEN};
    # Pass call frame to Exporter's import for further processing
    goto &Exporter::import;
}

BEGIN {
    no warnings 'once';
    # There are some useful symbols defined elsewhere that I'd like to
    # make available (alias) via the root namespace.
    *api_key         = *WebService::Shippo::Resource::api_key;
    *api_credentials = *WebService::Shippo::Resource::api_credentials;
    *pretty          = *WebService::Shippo::Object::pretty;
    *response        = *WebService::Shippo::Request::response;
    *Shippo::        = *WebService::Shippo::;
}

1;

=pod

=encoding utf8

=head1 UNDER CONSTRUCTION

B<Though functional, this software is still in the process of being
documented and should, therefore, be considered a work in progress.> 

=head1 NAME

WebService::Shippo - Shippo API Client

=head1 SYNOPIS

B<Note>: though scripts and modules must always C<use WebService::Shippo;>
to import the client software, the C<WebService::> portion of that package
namespace may be dropped when subsequently referring to the main package
or any of its resource classes. For example, C<WebService::Shippo::Address>
and C<Shippo::Address> refer to the same class. 

To compel the developer to continue using the C<WebService::> prefix does
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
C<LWP::UserAgent> package:

=over 2

=item * L<https://github.com/cpanic/WebService-Shippo/blob/master/sample.png>

=back

=head1 DESCRIPTION

Shippo connects you with multiple shipping providers (USPS, UPS and Fedex,
for example) through one interface, offering you great discounts on a
selection of shipping rates. You can sign-up for an account at 
L<https://goshippo.com/>.

The Shippo API can be used to automate and customize shipping capabilities
for your e-commerce store or marketplace, enabling you to retrieve shipping 
rates, create and purchase shipping labels, track packages, and much more.

Though Shippo I<do> offer official API clients for a bevy of major languages, 
the venerable Perl 5 was not included in that list. This community offering 
attempts to correct that omission ;-)

=head2 API Resources

Access to all Shippo API resources is via URLs relative to the same encrypted
API endpoint (https://api.goshippo.com/v1/).

There are resource item classes to help with the nitty-gritty of interacting
each type of resource:

=over 2

=item * Addresses

=item * Parcels

=item * Shipments

=item * Rates

=item * Transactions

=item * Customs Items

=item * Customs Declarations

=item * Refunds

=item * Manifests

=item * Carrier Accounts

=back

Each item class has a related collection class with a similar name I<in the
plural form>. The rationale behind this is that the Shippo API can be used
to retrieve single objects with the C<fetch> method, and collections of
objects with the C<all> method, and different behaviours may be applied
to collections, which is why both forms exist.

=head2 Request & Response Data

The Perl client ensures that requests are properly encoded and passed to the
correct API endpoints using appropriate HTTP methods. There is documentation
for each API resource, containing more details on the values accepted by and
returned for a given resource (see L<FULL API DOCUMENTATION>).

All API requests return responses encoded as JSON strings, which the client
converts into Perl blessed object references of the correct type. As a rule,
any resource attribute documented in the API specification will have an
accessor of the same same in a Perl instance of that object.

=head2 REST & Disposable Objects

The Shippo API is built with simplicity and RESTful principles in mind:
B<POST> requests are used to create objects, B<GET> requests to fetch and
list objects, and B<PUT> requests to update objects. The Perl client provides
C<create>, C<fetch>, C<all> and C<update> methods for use with resource
objects that permit such operations.

Addresses, Parcels, Shipments, Rates, Transactions, Refunds, Customs Items and
Customs Declarations are disposable objects. This means that once you create
an object, you cannot change it. Instead, create a new one with the desired
values. Carrier Accounts are the exception and may be updated via B<PUT>
requests.

=head1 METHODS

=head2 api_key

Get or set the key used by API requests for Shippo's token-based
authentication. This is Shippo's preferred method of authentication.

=over 2

=item * Return the token currently being used for authentication.

    my $api_key = Shippo->api_key;

=item * Set the token to be used for authentication.
    
    Shippo->api_key($auth_token);

The C<api_key> method is chainable when used as a setter.

=back

=head2 api_credentials

Get or set the login credentials used by API requests for Shippo's legacy
authentication. Legacy authentication means encoding the HTTP Authorization
header for Basic Authentication so, even though requests and repsonses are
encrypted, you should still consider using the token-based authentication
instead (see C<api_key>). 

=over 2

=item * Return the login credentials currently being used for authentication.

    my ($username, $password) = Shippo->api_credentials;

=item * Set the credentials to be used for authentication.

    Shippo->api_credentials($username, $password);

The C<api_credentials> method is chainable when used as a setter.

=back

Whenever a configuration specifies both token and login credentials, the
client will always favour token-based authentication. If C<api_key> and
C<api_credentials> are both set manually then it is the most recently
set mechanism that defines the HTTP Authorization header.

=head2 pretty

Get or set the state of the attribute influencing the default readability
of objects serialized as JSON using the C<to_json> method or automatic
stringification.

=over 2

=item * Return the current state of the C<pretty> attribute.
 

    my $boolean = Shippo->pretty;

=item * Set the state of the C<pretty> attribute.

    Shippo->pretty($boolean);

=back

B<Note>: the C<to_json> method also takes optional boolean argument that
may be set to C<true> or C<false> to achieve the same effect for a single
serialization, regardless of the default currently in force.
 
=head2 response

    my $last_response = Shippo->response;

Returns a copy of the C<L<HTTP::Response>> resulting from the most recent request.

=head1 EXPORTS

The C<WebService::Shippo> package exports a number of helpful subroutines by
default:

=head2 true

    my $fedex_account = Shippo::CarrierAccount->create(
        carrier    => 'fedex',
        account_id => '<YOUR-FEDEX-ACCOUNT-NUMBER>',
        parameters => { meter => '<YOUR-FEDEX-METER-NUMBER>' },
        test       => true,
        active     => true
    );

Returns a scalar value which will evaluate to true. 

Since the I<lingua franca> connecting Shippo's API and the Perl client is
JSON, it can feel more natural to think in those terms. Thus, C<true> may be
used in place of C<1>. Now, when creating a new object from a JSON example,
any literal and accidental use of C<true> or C<false> is much less likely
to result in misery.

See Ingy's L<boolean> package for more guidance.

=head2 false

    my $fedex_account = Shippo::CarrierAccount->create(
        carrier    => 'fedex',
        account_id => '<YOUR-FEDEX-ACCOUNT-NUMBER>',
        parameters => { meter => '<YOUR-FEDEX-METER-NUMBER>' },
        test       => false,
        active     => false
    );

Returns a scalar value which will evaluate to false. 

Since the I<lingua franca> connecting Shippo's API and the Perl client is
JSON, it can feel more natural to think in those terms. Thus, C<false> may be
used in place of C<0>. Now, when creating a new object from a JSON example,
any literal and accidental use of C<true> or C<false> is much less likely
to result in misery.

See Ingy's L<boolean> package for more guidance.

=head2 boolean

    my $bool = boolean($value);

Casts a scalar value to a boolean value (C<true> or C<false>).

See Ingy's L<boolean> package for more guidance.

=head2 callback

    Shippo::CarrierAccounts->all(callback {
        $_->enable_test_mode;
    });
    
Returns a blessed C<sub> suitable for use as a callback. Some methods accept
optional blocking callbacks in order to facilitate list transformations, so
this package makes C<&Params::Callbacks::callback> available for use.

See L<Params::Callbacks> for more guidance.

=head1 CONFIGURATION

While the client does provide C<api_key> and C<api_credentials> methods to
help with authentication, hard-coding such calls in anything more mission 
critical than a simple test script may I<not> be the best way to go.

As soon as it is imported, one of the first things the client does is search
a number of locations for a L<YAML-encoded|https://en.wikipedia.org/wiki/YAML>
configuration file. The first one it finds is loaded.

In order, the locations searched are as follows:

=over 2

=item * C<./.shipporc>

=item * C</I<path>/I<to>/I<home>/.shipporc>

=item * C</I<etc>/shipporc>

=item * C</I<path>/I<to>/I<perl>/I<module>/I<install>/I<lib>/WebService/Shippo/Config.yml>

=back

The configuration file is very simple and needs to have the following
structure, though not all elements are mandatory:

    ---
    username: martymcfly@pinheads.org
    password: yadayada
    private_token: f0e1d2c3b4a5968778695a4b3c2d1e0f96877869
    public_token: 96877869f0e1d2c3b4a5968778695a4b3c2d1e0f
    default_token: private_token

At a minimum, your configuration should define values for C<private_token> and
C<public_token>. These are your Shippo Private and Publishable Auth tokens,
which are found on your L<Shippo API page|https://goshippo.com/user/apikeys/>.

=head1 FULL API DOCUMENTATION

=over 2

=item * For API documentation, go to L<https://goshippo.com/docs/>

=item * For API support, contact L<mailto:support@goshippo.com> with any 
questions.

=back

=head1 SEE ALSO

=head2 Shippo Objects

=over 2

=item * L<WebService::Shippo::Address>

=item * L<WebService::Shippo::Parcel>

=item * L<WebService::Shippo::Shipment>

=item * L<WebService::Shippo::Rate>

=item * L<WebService::Shippo::Transaction>

=item * L<WebService::Shippo::CustomsItem>

=item * L<WebService::Shippo::CustomsDeclaration>

=item * L<WebService::Shippo::Refund>

=item * L<WebService::Shippo::Manifest>

=item * L<WebService::Shippo::CarrierAccount>

=back

=head2 Shippo Collections

=over 2

=item * L<WebService::Shippo::Addresses>

=item * L<WebService::Shippo::Parcels>

=item * L<WebService::Shippo::Shipments>

=item * L<WebService::Shippo::Rates>

=item * L<WebService::Shippo::Transactions>

=item * L<WebService::Shippo::CustomsItems>

=item * L<WebService::Shippo::CustomsDeclarations>

=item * L<WebService::Shippo::Refunds>

=item * L<WebService::Shippo::Manifests>

=item * L<WebService::Shippo::CarrierAccounts>

=back

=head1 REPOSITORY

=over 2

=item * L<https://github.com/cpanic/WebService-Shippo>

=item * L<https://github.com/cpanic/WebService-Shippo/wiki>

=back

=head1 AUTHOR

Iain Campbell <cpanic@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright E<copy> 2015 by Iain Campbell.

You may distribute this software under the terms of either the GNU General
Public License or the Artistic License, as specified in the Perl README
file.


=cut
