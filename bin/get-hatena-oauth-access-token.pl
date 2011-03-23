#!/usr/bin/perl
use strict;
use warnings;
use OAuth::Lite::Consumer;
use URI::Escape;

sub usage () { die "Usage: $0 consumer-key consumer-secret scope1,scope2,...\n" }

my $consumer_key = shift or usage;
my $consumer_secret = shift or usage;
my $scopes = shift or usage;

my $consumer = OAuth::Lite::Consumer->new(
    consumer_key       => $consumer_key,
    consumer_secret    => $consumer_secret,
    site               => q{https://www.hatena.com},
    request_token_path => q{/oauth/initiate},
    access_token_path  => q{/oauth/token},
    authorize_path     => q{https://www.hatena.ne.jp/oauth/authorize},
);

my $request_token = $consumer->get_request_token(
    callback_url => q{http://localhost/callback},
    scope        => $scopes,
) or die $consumer->errstr;

my $url = $consumer->url_to_authorize(token => $request_token);
print STDERR "Open <", $url, "> in your browser, accept the application, and then input redirected URL: ";

while (1) {
    my $redirected = <STDIN>;
    if ($redirected =~ /\boauth_verifier=([^&;\s]+)/) {
        my $verifier = uri_unescape $1;
        my $access_token = $consumer->get_access_token(
            token    => $request_token,
            verifier => $verifier,
        ) or die $consumer->errstr;
        
        print "Access token: " . $access_token->token, "\n";
        print "Access secret: " . $access_token->secret, "\n";
        last;
    }
}

__END__

=head1 NAME

get-hatena-oauth-access-token - A simple script to obtain Hatena OAuth 1.0 access token

=head1 SYNOPSIS

  get-hatena-oauth-access-token consumer-key consumer-secret scope1,scope2,...

... where I<consumer-key> and I<consumer-secret> are tokens
identifying your application, I<scope1>, I<scope2>, ... are Hatena
OAuth scope names such as C<read_public>, C<write_private>, and so on.

=head1 SEE ALSO

OAuth for Hatena Services
<http://developer.hatena.ne.jp/ja/documents/auth/apis/oauth> (In
Japanese).

=head1 AUTHORS

Wakaba (id:wakabatan) <wakabatan@hatena.ne.jp>, id:shiba_yu36.

=head1 LICENSE

Copyright 2010-2011 Hatena <http://www.hatena.ne.jp/>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
