package Perl5::Party::Posts;

use base 'Mojo::Base';

use Text::MultiMarkdown qw/markdown/;
use File::Glob qw/bsd_glob/;
use Mojo::Util qw/slurp/;

sub all {
    my @posts = bsd_glob 'post/*.md';
    s/\.md$// for @posts;
    my @return;
    for ( @posts ) {
        my $post = slurp "$_.md";
        my ($meta) = process($post);
        next if $meta->{draft};
        push @return, {
            name    => $_,
            date    => $meta->{date},
            title   => $meta->{title},
            link    => "/$_",
       };
    }
    return [ sort { $b->{date} cmp $a->{date} } @return ];
}

sub load {
    my ($self, $post) = @_;
    return unless -e "post/$post.md";
    my ($meta, $content) = process( slurp "post/$post.md" );
    return $meta, markdown $content;
}

sub process {
    my $post = shift;
    my %meta;
    $meta{ $1 } = $2 while $post =~ s/^%%\s*(\w+)\s*:\s*([^\n]+)\n//;
    return \%meta, $post;
}


1;