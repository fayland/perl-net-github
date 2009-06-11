package Net::GitHub::V2::Issues;

use Moose;

our $VERSION = '0.17';
our $AUTHORITY = 'cpan:FAYLAND';

with 'Net::GitHub::V2::HasRepo';

use URI::Escape;

sub search {
    my ( $self, $state, $word ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    my $url   = "issues/search/$owner/$repo/$state/" . uri_escape($word);
    
    return $self->get_json_to_obj( $url, 'issues' );
}

sub list {
    my ( $self, $state ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "issues/list/$owner/$repo/$state", 'issues' );
}

sub view {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj( "issues/show/$owner/$repo/$id", 'issue' );
}

sub open {
    my ( $self, $title, $body ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/open/$owner/$repo",
        title => $title,
        body  => $body,
        'issue'
    );
}
sub close {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/close/$owner/$repo/$id", 'issue' );
}
sub reopen {
    my ( $self, $id ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/reopen/$owner/$repo/$id", 'issue' );
}

sub edit {
    my ( $self, $id, $title, $body ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    return $self->get_json_to_obj_authed( "issues/edit/$owner/$repo/$id",
        title => $title,
        body  => $body,
        'issue'
    );
}

sub add_label {
    my ( $self, $id, $label ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url = $self->api_url_https . "issues/label/add/$owner/$repo/$label/$id";
    return $self->get_json_to_obj_authed( $url, 'labels' );
}
sub remove_label {
    my ( $self, $id, $label ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url = $self->api_url_https . "issues/label/remove/$owner/$repo/$label/$id";
    return $self->get_json_to_obj_authed( $url, 'labels' );
}

sub comment {
    my ( $self, $id, $text ) = @_;
    
    my $owner = $self->owner;
    my $repo  = $self->repo;
    
    my $url = $self->api_url_https . "issues/comment/$owner/$repo/$id";
    return $self->get_json_to_obj_authed( $url,
        comment => $text,
        'comment'
    );
}

sub comments {
    my ( $self, $id ) = @_;
    my $owner   = $self->owner;
    my $repo    = $self->repo;
    my $content = $self->get("http://github.com/$owner/$repo/issues#issue/$id");
    require HTML::TreeBuilder;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;
    my $comments_region = $tree->look_down( class => "comments commentstyle" );
    if ($comments_region) {
        my @comments_tree =
          $comments_region->look_down( class => 'comment wikistyle' );
        my @comments;
        for my $c (@comments_tree) {
            my ($id) = $c->attr('id') =~ /comment_(\d+)/;
            my $meta    = $c->look_down( class => 'meta' );
            my $author  = $meta->find_by_tag_name('b')->as_text;
            my $date =
              $meta->look_down( class => 'date' )
              ->look_down( class => 'relatize' )->attr('title');
            # hack $date to make it consistent with official api
            $date =~ s!-!/!g;
            $date .= ' -0700';

            my $content = $c->look_down( class => 'body' )->as_text;
            push @comments,
              {
                id      => $id,
                author  => $author,
                date    => $date,
                content => $content,
              };
        }
        return \@comments;
    }
    else {
        return [];
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::GitHub::V2::Issues - GitHub Issues API

=head1 SYNOPSIS

    use Net::GitHub::V2::Issues;

    my $issue = Net::GitHub::V2::Issues->new(
        owner => 'fayland', repo => 'perl-net-github'
    );

=head1 DESCRIPTION

L<http://develop.github.com/p/issues.html>

For those B<(authentication required)> below, you must set login and token (in L<https://github.com/account>)

    my $issue = Net::GitHub::V2::Issues->new(
        owner => 'fayland', repo => 'perl-net-github',
        login => 'fayland', token => '54b5197d7f92f52abc5c7149b313cf51', # faked
    );

=head1 METHODS

=over 4

=item search

    my $issues = $issue->search('open', 'test');

search issues

=item list

    my $issues = $issue->list('open');
    my $issues = $issue->list('closed');

see a list of issues for a project.

each issue is a hash reference which contains:

    'number' => 2,
    'position' => '1',
    'state' => 'open',
    'body' => 'Bug Detail',
    'created_at' => '2009/04/20 10:00:45 -0700',
    'updated_at' => '2009/04/20 10:00:45 -0700',
    'user' => 'foobar',
    'title' => 'Bug Title',
    'votes' => 0


=item view

    my $iss = $issue->view( $issues->[0]->{number} );

get data on an individual issue by number

=item open

    my $iss = $issue->open( 'Bug title', 'Bug detail' );

open a new issue on a project (authentication required)

=item close

=item reopen

    $issue->close( $number );
    $issue->reopen( $number );

close or reopen an issue (authentication required)

=item edit

    $issue->edit( $number, 'New bug title', 'New bug detail' );

edit an existing issue (authentication required)

=item add_label

=item remove_label

    my $labels = $issue->add_label( $number, 'testing' );
    my $labels = $issue->remove_label( $number, $label );

add/remove a label (authentication required)

=item comment

    my $comment = $issue->comment( $number, 'this is amazing' );

comment on issues

=item comments

note: this is not the official api of github, in fact,
      it's done by scrapping.

    my $comments = $issue->comments( $number );

return an arrayref containing a list of comments, each comment is a hashref like

    {
        id      => 12345,
        author  => 'foo',
        date    => '2009/06/08 18:28:42 -0700',
        content => 'blalba',
    }

if no comments, return []

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
