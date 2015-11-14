use strict;
use warnings;
use MRO::Compat 'c3';

package WebService::Shippo::Refund;
use base qw(
    WebService::Shippo::Item
    WebService::Shippo::Create
    WebService::Shippo::Fetch
    WebService::Shippo::Async
);

sub api_resource ()     { 'refunds' }

sub collection_class () { 'WebService::Shippo::Refunds' }

sub item_class ()       { __PACKAGE__ }

BEGIN {
    no warnings 'once';
    *Shippo::Refund::  = *WebService::Shippo::Refund::;
}

1;

=pod

=encoding utf8

=head1 NAME

WebService::Shippo::CarrierAccount - Refund class

=head1 DESCRIPTION

Refunds are reimbursements for successfully created but unused 
L<Transactions|WebService::Shippo::Transaction>.

Please keep the following in mind:

=over 2

=item * Once a Refund has been claimed, you must not use the shipping label
for actual postage.

=item * Refunds take several days to be processed.

=item * Some carriers (e.g. FedEx and UPS) don't require refunds, since
the corresponding labels will only be charged after they have been scanned;
however, the Shippo refund may be used for refunding of the $0.05 Shippo
label fee.

=back

=head1 API DOCUMENTATION

For more information about Refunds, consult the Shippo API
documentation:

=over 2

=item * L<https://goshippo.com/docs/#refunds>

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
