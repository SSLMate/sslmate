#
# Copyright (c) 2014-2015 Opsmate, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the name(s) of the above copyright
# holders shall not be used in advertising or otherwise to promote the
# sale, use or other dealings in this Software without prior written
# authorization.
#

package SSLMate::HTTPSClient;

use 5.010;	# 5.10
use strict;
use warnings;

use SSLMate;
use IPC::Open2;
use URI::Escape;
use POSIX qw(:sys_wait_h);

our $TIMEOUT = 300;

sub new_curl {
	my $curl = WWW::Curl::Easy->new;
	$curl->setopt(WWW::Curl::Easy::CURLOPT_PROTOCOLS(), 3);		# Only safe protocols (HTTP and HTTPS, not SMTP, SSH, etc.)
	$curl->setopt(WWW::Curl::Easy::CURLOPT_FOLLOWLOCATION(), 1);	# Follow redirects
	$curl->setopt(WWW::Curl::Easy::CURLOPT_MAXREDIRS(), 20);	# Allow at most 20 redirections
	$curl->setopt(WWW::Curl::Easy::CURLOPT_SSL_VERIFYPEER(), 1);	# Check certificates
	$curl->setopt(WWW::Curl::Easy::CURLOPT_SSL_VERIFYHOST(), 2);	# Check certificates (2 is not a typo)
	$curl->setopt(WWW::Curl::Easy::CURLOPT_USERAGENT(), "SSLMate/$SSLMate::VERSION WWW-Curl/$WWW::Curl::VERSION");
	$curl->setopt(WWW::Curl::Easy::CURLOPT_TIMEOUT(), $TIMEOUT);
	return $curl;
}

sub new_lwp_ua {
	my $ua = LWP::UserAgent->new;
	$ua->agent("SSLMate/$SSLMate::VERSION ");
	$ua->protocols_allowed( [ 'http', 'https'] );
	$ua->ssl_opts(verify_hostname => 1);
	$ua->timeout($TIMEOUT);
	return $ua;
}


sub has_curl_command {
	my $pid = fork;
	die "Error: fork failed: $!" unless defined $pid;
	if ($pid == 0) {
		open(STDIN, '<', '/dev/null');
		open(STDOUT, '>', '/dev/null');
		open(STDERR, '>', '/dev/null');
		exec('curl', '--version');
		exit 1;
	}
	waitpid($pid, 0) or die "Error: waitpid failed: $!";
	return $? == 0;
}

sub escape_curl_param {
	my ($param) = @_;
	$param =~ s/\\/\\\\/g;
	$param =~ s/\"/\\\"/g;
	$param =~ s/\t/\\t/g;
	$param =~ s/\n/\\n/g;
	$param =~ s/\r/\\r/g;
	$param =~ s/\v/\\v/g;
	return $param;
}

sub decode_curl_error {
	my ($exit_code) = @_;

	return "Unable to resolve server address" if $exit_code == 6;
	return "Unable to connect to server" if $exit_code == 7;
	return "Timeout" if $exit_code == 28;
	return "SSL handshake failed" if $exit_code == 35;
	return "SSL certificate error" if $exit_code == 51;
	return "SSL certificate cannot be authenticated" if $exit_code == 60;

	return "curl exited with status $exit_code";
}



sub request_via_lwp {
	my $self = shift;
	my ($method, $uri, $headers, $creds, $post_data) = @_;

	$self->{ua} //= new_lwp_ua;
	my $req = HTTP::Request->new($method, $uri);
	if (defined $headers) {
		for my $name (keys %$headers) {
			$req->header($name => $headers->{$name});
		}
	}
	if (defined $creds) {
		die "Usernames may not contain colons\n" if $creds->{username} =~ /:/;
		$req->authorization_basic($creds->{username}, $creds->{password});
	}
	if (defined $post_data) {
		$req->content($post_data);
	}

	my $response = $self->{ua}->request($req);
	if (defined(my $msg = $response->header('X-Died'))) {
		# This is how LWP::UserAgent reports timeouts
		die "$msg\n";
	}
	if (($response->header('Client-Warning')//'') eq 'Internal response') {
		die $response->content . "\n";
	}

	return ($response->code, $response->content_type, \$response->content);
}

sub request_via_curl_module {
	my $self = shift;
	my ($method, $uri, $headers, $creds, $post_data) = @_;
	my @headers;

	$self->{curl} //= new_curl;
	$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), $method);
	if (defined $post_data) {
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_HTTPGET(), 0);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_NOBODY(), 0);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_UPLOAD(), 0);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDS(), $post_data);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDSIZE(), length $post_data);
	} else {
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_HTTPGET(), 1);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_UPLOAD(), 0);
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_NOBODY(), $method eq 'HEAD' ? 1 : 0);
	}
	if ($headers) {
		for my $name (keys %$headers) {
			my $value = $headers->{$name};
			push @headers, "$name: $value";
		}
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_HTTPHEADER(), \@headers);
	}
	if ($creds) {
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_USERNAME(), $creds->{username});
		$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_PASSWORD(), $creds->{password});
	}
	$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_URL(), $uri);

	my $response_data = '';
	open(my $response_fh, '>', \$response_data);
	$self->{curl}->setopt(WWW::Curl::Easy::CURLOPT_WRITEDATA(), $response_fh);

	my $result = $self->{curl}->perform;
	close($response_fh);
	if ($result != 0) {
		my $err = $self->{curl}->strerror($result);
		undef $self->{curl};
		die "$err\n";
	}
	my $http_status = $self->{curl}->getinfo(WWW::Curl::Easy::CURLINFO_HTTP_CODE());
	my $content_type = $self->{curl}->getinfo(WWW::Curl::Easy::CURLINFO_CONTENT_TYPE());

	return ($http_status, $content_type, \$response_data);
}

sub request_via_curl_command {
	my $self = shift;
	my ($method, $uri, $headers, $creds, $post_data) = @_;

	local $SIG{PIPE} = 'IGNORE';

	my ($response_fh, $config_fh);
	my $curl_pid = eval { open2($response_fh, $config_fh, 'curl', '-q', '-K', '-') };
	die "Unable to execute the 'curl' command - is curl installed?\n" unless defined($curl_pid);
	print $config_fh "user-agent = \"" . escape_curl_param("SSLMate/$SSLMate::VERSION curl") . "\"\n";
	print $config_fh "silent\n";
	print $config_fh "include\n";
	print $config_fh "max-time = \"" . escape_curl_param($TIMEOUT) . "\"\n";
	print $config_fh "request = \"" . escape_curl_param($method) . "\"\n";
	print $config_fh "url = \"" . escape_curl_param($uri) . "\"\n";
	if ($headers) {
		for my $name (keys %$headers) {
			my $value = $headers->{$name};
			print $config_fh "header = \"" . escape_curl_param("$name: $value") . "\"\n";
		}
	}
	if ($creds) {
		print $config_fh "user = \"" . escape_curl_param(join(':', $creds->{username}, $creds->{password})) . "\"\n";
	}
	if ($method eq 'POST') {
		$post_data //= '';
		print $config_fh "data = \"" . escape_curl_param($post_data) . "\"\n";
	}
	close($config_fh);

	my ($http_status, $content_type, $response_data);
	if (!eof($response_fh)) {
		do {
			# HTTP/1.1 200 OK
			my $http_status_line = <$response_fh>;
			$http_status_line =~ s/\r?\n$//;
			(undef, $http_status, undef) = split(' ', $http_status_line);

			# Content-Type: application/json
			$content_type = undef;
			while (defined(my $line = <$response_fh>)) {
				$line =~ s/\r?\n$//;
				last if $line eq ''; # end of headers
				if ($line =~ /^Content-Type:\s*(.*)$/i) {
					$content_type = $1;
				}
			}
		} while ($http_status == 100);

		$response_data = do { local $/; <$response_fh> };
	}
	close($response_fh);
	waitpid($curl_pid, 0) or die "waitpid failed: $!";
	if ($? != 0) {
		if (WIFEXITED($?)) {
			die decode_curl_error(WEXITSTATUS($?)) . "\n";
		} else {
			die "curl command terminated with status $?\n";
		}
	}
	if (not $http_status) {
		die "curl command produced unexpected output\n";
	}

	return ($http_status, $content_type, \$response_data);
}

sub request {
	my $self = shift;
	my ($method, $uri, $headers, $creds, $post_data) = @_;

	if ($self->{has_curl_command}) {
		return $self->request_via_curl_command($method, $uri, $headers, $creds, $post_data);
	} elsif ($self->{has_lwp}) {
		return $self->request_via_lwp($method, $uri, $headers, $creds, $post_data);
	} elsif ($self->{has_curl_module}) {
		return $self->request_via_curl_module($method, $uri, $headers, $creds, $post_data);
	} else {
		die "Neither LWP (>= 6) nor the curl command are installed\n";
	}
}

sub new {
	my $class = shift;
	my $self = {
		has_curl_command => has_curl_command,
		has_curl_module => eval { require WWW::Curl::Easy; 1 } // 0,
		has_lwp => eval { require LWP::UserAgent; require LWP::Protocol::https; $LWP::UserAgent::VERSION >= 6 && $LWP::Protocol::https::VERSION >= 6 } // 0, # LWP5 does not properly validate certs!
	};
#	print STDERR "has_curl_command=" . $self->{has_curl_command} . "\n";
#	print STDERR "has_curl_module=" . $self->{has_curl_module} . "\n";
#	print STDERR "has_lwp=" . $self->{has_lwp} . "\n";
	bless $self, $class;
	return $self;
}

sub qs_escape {
	my ($str) = @_;
	return uri_escape_utf8($str, '^A-Za-z0-9\-\._');
}

sub make_query_string {
	my ($request_data) = @_;

	my @elts;
	for my $key (keys %$request_data) {
		next unless defined $request_data->{$key};
		if (ref($request_data->{$key}) eq 'ARRAY') {
			for my $value (@{$request_data->{$key}}) {
				next unless defined $value;
				push @elts, qs_escape($key) . '=' . qs_escape($value);
			}
		} elsif (ref($request_data->{$key}) eq 'SCALAR') {
			push @elts, qs_escape($key) . '=' . qs_escape(${$request_data->{$key}});
		} else {
			push @elts, qs_escape($key) . '=' . qs_escape($request_data->{$key});
		}
	}
	$request_data = join('&', @elts);
}

1;
