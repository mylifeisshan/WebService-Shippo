use strict;
use warnings;
use MRO::Compat 'c3';

package WebService::Shippo::Transaction;
use Carp         ( 'confess' );
use Scalar::Util ( 'blessed' );
use base (
    'WebService::Shippo::Resource',
    'WebService::Shippo::Creator',
    'WebService::Shippo::Fetcher',
    'WebService::Shippo::Async',
);

sub api_resource ()     { 'transactions' }
sub collection_class () { 'WebService::Shippo::Transactions' }
sub item_class ()       { __PACKAGE__ }

sub get_shipping_label
{
    my ( $invocant, $transaction_id, %params ) = @_;
    confess "Expected a transaction id"
        unless $transaction_id;
    my $transaction;
    if ( $invocant->is_same_object( $transaction_id ) ) {
        $transaction = $invocant;
    }
    else {
        $transaction = WebService::Shippo::Transaction->fetch( $transaction_id );
    }
    $transaction->wait_if_status_in( 'QUEUED', 'WAITING' )
        unless $params{async};
    return $transaction->label_url;
}
package    # Hide from PAUSE
    WebService::Shippo::Transactions;
use base ( 'WebService::Shippo::Collection' );

sub item_class ()       { 'WebService::Shippo::Transaction' }
sub collection_class () { __PACKAGE__ }

BEGIN {
    no warnings 'once';
    # Forcing the dev to always use CPAN's perferred "WebService::Shippo"
    # namespace is just cruel; allow the use of "Shippo", too.
    *Shippo::Transaction::     = *WebService::Shippo::Transaction::;
    *Shippo::TransactionList:: = *WebService::Shippo::TransactionList::;
}

1;

=pod

=encoding utf8

=head1 NAME

WebService::Shippo::Transaction - Shippo Transaction class.

=head1 DESCRIPTION

A Transaction is the purchase of a shipment label for a given shipment
rate. Transactions can be as simple as posting a rate identifier, but
also allow you to define further label parameters, such as pickup and
notifications.

Transactions can only be created for rates that are less than 7 days
old and whose C<object_purpose> attribute is B<PURCHASE>.

Transactions are created asynchronously. The response time depends
exclusively on the carrier's server.

=head1 API DOCUMENTATION

For more information about Transactions, consult the Shippo API
documentation:

=over 2

=item * L<https://goshippo.com/docs/#transactions>

=back

=head1 REPOSITORY

=over 2

=item * L<https://github.com/cpanic/WebService-Shippo>

=item * L<https://github.com/cpanic/WebService-Shippo/wiki>

=back

=head1 AUTHOR

Iain Campbell <cpanic@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Iain Campbell.

You may distribute this software under the terms of either the GNU General
Public License or the Artistic License, as specified in the Perl README
file.

=cut
