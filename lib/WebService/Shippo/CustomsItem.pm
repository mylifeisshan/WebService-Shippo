use strict;
use warnings;
use MRO::Compat 'c3';

package WebService::Shippo::CustomsItem;
use base qw(
    WebService::Shippo::Item
    WebService::Shippo::Create
    WebService::Shippo::Fetch
);

sub api_resource ()     { 'customs/items' }

sub collection_class () { 'WebService::Shippo::CustomsItems' }

sub item_class ()       { __PACKAGE__ }

BEGIN {
    no warnings 'once';
    *Shippo::CustomsItem:: = *WebService::Shippo::CustomsItem::;
}

1;

=pod

=encoding utf8

=head1 NAME

WebService::Shippo::CustomsItem - Customs Item class

=head1 DESCRIPTION

Customs items are distinct items in your international shipment parcel.

=head1 API DOCUMENTATION

For more information about Customs Items, consult the Shippo API
documentation:

=over 2

=item * L<https://goshippo.com/docs/#customsitems>

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
