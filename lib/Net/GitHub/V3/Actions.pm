package Net::GitHub::V3::Actions;

use Moo;

our $VERSION   = '1.00';
our $AUTHORITY = 'cpan:FAYLAND';

use Carp;
use URI::Escape;
use URI;
use HTTP::Request::Common qw(POST);

with 'Net::GitHub::V3::Query';

## build methods on fly
my %__methods = (

    ### -------------------------------------------------------------------------------
    ### Artifacts
    ### -------------------------------------------------------------------------------

    # List artifacts for a repository
    artifacts => { v => 2,  url => '/repos/:owner/:repo/actions/artifacts', method => 'GET', paginate => 1 },

    # List workflow run artifacts
    # GET /repos/:owner/:repo/actions/runs/:run_id/artifacts
    run_artifacts => { v => 2, url => '/repos/:owner/:repo/actions/runs/:run_id/artifacts', method => 'GET', paginate => 1 },

    # Get an artifact
    # GET /repos/:owner/:repo/actions/artifacts/:artifact_id
    artifact => {  v => 2, url => '/repos/:owner/:repo/actions/artifacts/:artifact_id', method => 'GET' },

    ### -------------------------------------------------------------------------------
    ### Workflows - https://developer.github.com/v3/actions/workflows/
    ### -------------------------------------------------------------------------------

    # List repository workflows
    # GET /repos/:owner/:repo/actions/workflows
    workflows => { v => 2, url => '/repos/:owner/:repo/actions/workflows', method => 'GET', paginate => 1 },

    # Get a workflow
    # GET /repos/:owner/:repo/actions/workflows/:workflow_id
    workflow => {  v => 2, url => '/repos/:owner/:repo/actions/workflows/:workflow_id', method => 'GET' },

    ### -------------------------------------------------------------------------------
    ### Workflow Jobs - https://developer.github.com/v3/actions/workflow-jobs/
    ### -------------------------------------------------------------------------------

    # List jobs for a workflow run
    # GET /repos/:owner/:repo/actions/runs/:run_id/jobs pagination
    jobs => {  v => 2, url => '/repos/:owner/:repo/actions/runs/:run_id/jobs', method => 'GET', paginate => 1 },

    # Get a workflow job
    # GET /repos/:owner/:repo/actions/jobs/:job_id
    job => {  v => 2, url => '/repos/:owner/:repo/actions/jobs/:job_id', method => 'GET' },

    ### -------------------------------------------------------------------------------
    ### Workflow Runs - https://developer.github.com/v3/actions/workflow-runs/
    ### -------------------------------------------------------------------------------

    runs => { v => 2, url => '/repos/:owner/:repo/actions/workflows/:workflow_id/runs', method => 'GET', paginate => 1 },

    # ...
);
__build_methods( __PACKAGE__, %__methods );

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::Actions - GitHub Actions API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $actions = $gh->actions;

    # set :user/:repo for simple calls
    $actions->set_default_user_repo('fayland', 'perl-net-github');

    $actions->workflows();
    $actions->workflows( { owner => 'xxx', repo => 'repo' } );


=head1 DESCRIPTION

=head2 METHODS

=head3 GitHub Actions

L<https://developer.github.com/v3/actions/>

=head3 Artifacts

L<https://developer.github.com/v3/actions/artifacts/>

=over 4

=item artifacts

List artifacts for a repository

    $actions->artifacts( { owner => 'xxx', repo => 'repo' } );

=item run_artifacts

    $actions->run_artifacts( { owner => 'xxx', repo => 'repo', run_id => XXX } );

=item artifact

    $actions->artifacts( { owner => 'xxx', repo => 'repo', artifact_id => 'ID' } );

=back

=head3 Workflows

L<https://developer.github.com/v3/actions/workflows/>

=over 4

=item workflows

List repository workflows

    $actions->workflows( { owner => 'xxx', repo => 'repo' } );

=item workflow

Get a workflow

    $actions->workflow( { owner => 'xxx', repo => 'repo', workflow_id => 1234 } );

=back

=head3 Workflow Jobs

L<https://developer.github.com/v3/actions/workflow-jobs/>

=over 4

=item jobs

List jobs for a workflow run

=item job

Get a workflow job

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
