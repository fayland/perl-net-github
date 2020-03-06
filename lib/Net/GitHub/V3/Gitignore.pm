package Net::GitHub::V3::Gitignore;

use Moo;

our $VERSION = '0.96';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub templates {
    my ( $self, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { type => $args };
    }

    my $uri = URI->new('/gitignore/templates');
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

sub template {
    my ( $self, $template, $args ) = @_;

    # for old
    unless (ref($args) eq 'HASH') {
        $args = { type => $args };
    }

    my $uri = URI->new("/gitignore/templates/" . uri_escape($template));
    $uri->query_form($args);
    return $self->query($uri->as_string);
}

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::Gitignore - GitHub Gitignore API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $gitignore = $gh->gitignore;

=head1 DESCRIPTION

=head2 METHODS

=head3 Gitignore

L<http://developer.github.com/v3/gitignore/>

=over 4

=item templates

    my @templates = $gitignore->templates();

=item template

    my $template = $gitignore->template('Perl');

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
