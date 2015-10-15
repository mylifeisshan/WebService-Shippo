use strict;
use warnings;
use MRO::Compat 'c3';

package WebService::Shippo::Resource;
use Carp ( 'croak' );
use namespace::clean;
use base ( 'WebService::Shippo::Object' );
use constant DEFAULT_API_SCHEME    => 'https';
use constant DEFAULT_API_HOST      => 'api.goshippo.com';
use constant DEFAULT_API_PORT      => '443';
use constant DEFAULT_API_BASE_PATH => 'v1';

{
    my $value = undef;

    sub api_private_token
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = $new_value;
        return $class;
    }
}

{
    my $value = undef;

    sub api_public_token
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = $new_value;
        return $class;
    }
}

{
    my $value = undef;

    sub api_key
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = $new_value;
        return $class;
    }
}

{
    my $value = DEFAULT_API_SCHEME;

    sub api_scheme
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = ( $new_value || DEFAULT_API_SCHEME );
        return $class;
    }

    BEGIN {
        no warnings 'once';
        *api_protocol = *api_scheme;
    }
}

{
    my $value = DEFAULT_API_HOST;

    sub api_host
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = ( $new_value || DEFAULT_API_HOST );
        return $class;
    }
}

{
    my $value = DEFAULT_API_PORT;

    sub api_port
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        $value = ( $new_value || DEFAULT_API_PORT );
        return $class;
    }
}

{
    my $value = DEFAULT_API_BASE_PATH;

    sub api_base_path
    {
        my ( $class, $new_value ) = @_;
        return $value unless @_ > 1;
        ( $value = $new_value || DEFAULT_API_BASE_PATH ) =~ s{(^\/*|\/*$)}{};
        return $class;
    }
}

sub api_resource
{
    croak 'Method not implemented in abstract base class';
}

sub url
{
    my ( $class ) = @_;
    my $scheme    = $class->api_scheme;
    my $port      = $class->api_port;
    my $path      = $class->api_base_path;
    my $resource  = $class->api_resource;
    my $url       = $scheme . '://';
    $url .= $class->api_host;
    $url .= ':' . $port
        unless $port && $port eq '443' && $scheme eq 'https';
    $url .= '/' . $path
        if $path;
    $url .= '/' . $resource
        if $resource;
    $url .= '/';
    return $url;
}

1;