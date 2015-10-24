use strict;
use warnings;
use MRO::Compat 'c3';

package WebService::Shippo::CustomsDeclaration;
use base (
    'WebService::Shippo::Resource',
    'WebService::Shippo::Creator',
    'WebService::Shippo::Fetcher',
    'WebService::Shippo::Lister',

);

sub api_resource { 'customs/declarations' }

package                               # Hide from PAUSE
    WebService::Shippo::CustomsDeclarationList;
use base ( 'WebService::Shippo::ObjectList' );

BEGIN {
    no warnings 'once';
    # Forcing the dev to always use CPAN's perferred "WebService::Shippo"
    # namespace is just cruel; allow the use of "Shippo", too.
    *Shippo::CustomsDeclaration:: = *WebService::Shippo::CustomsDeclaration::;
    *Shippo::CustomsDeclarationList::
        = *WebService::Shippo::CustomsDeclarationList::;
}

1;
