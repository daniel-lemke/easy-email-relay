# Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
# This software is licensed under the MIT License. See LICENSE for details.
package GUI;
use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);
use Cwd qw(getcwd);
use lib ".";
use MyConfig;

our $config_dir;
$config_dir = getcwd . '/config' unless $config_dir;

my %dispatch = (
	'/' => \&response_asset,
	'/index.css' => \&response_asset,
	'/index.js' => \&response_asset,
	'/get_log' => \&response_get_log,
	'/get_options' => \&response_get_options
);

sub handle_request {
	my ($self, $cgi) = @_;
	my $path = $cgi->path_info();
	my $handler = $dispatch{$path};

	if (ref $handler eq "CODE") {
		print "HTTP/1.0 200 OK\r\n";
		$handler->($cgi);
	} else {
		print "HTTP/1.0 404 Not Found\r\n";
		print $cgi->header,
			$cgi->start_html('Not found'),
			$cgi->h1('Not found'),
			$cgi->end_html;
	}
}

sub send_response {
	my $cgi = shift;
	return if !ref $cgi;

	my $path = $cgi->path_info;
}

sub response_asset {
	my $cgi = shift;
	return if !ref $cgi;

	my $path = $cgi->path_info;
	my $type;

	$path = '/index.html' if $path eq '/';
	open my $fh, "<", "www$path";
	my @f = <$fh>;
	close $fh;

	$type = 'text/plain';
	$type = 'text/html' if $path =~ /\.html/;
	$type = 'text/css' if $path =~ /\.css/;
	$type = 'text/js' if $path =~ /\.js/;

	print "Content-type: $type\r\n\r\n",
		join '', @f;
}

sub response_get_log {
	my $cgi = shift;
	return if !ref $cgi;

	my $path = $cgi->path_info;
	our $config_dir;
	my $config = MyConfig::read_config $config_dir;

	open my $fh, "<", $config->{logfile};
	my @log_file = <$fh>;
	close $fh;

	print "Content-type: text/plain\r\n\r\n",
		join '', @log_file;
}

sub response_get_options {
	my $cgi = shift;
	return if !ref $cgi;

	my $path = $cgi->path_info;
	our $config_dir;
	my $config = MyConfig::read_config $config_dir;

	open my $fh, "<", "$config_dir/config.txt";
	my @file = <$fh>;
	close $fh
	print "Content-type: text/plain\r\n\r\n",
		join '', @file;
}

