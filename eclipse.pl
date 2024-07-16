use strict;
use warnings;
use lib ".";
use config;
use ip;
use options;
use Log::Any qw($log);
use Log::Any::Adapter ('File', 'eclipse.log');
use XML::Parser;

my %ip_ports;


my $arg = shift @ARGV;
if ($arg && $arg eq '--create-ip-list') {
    options::create_list();
} elsif ($arg && $arg eq '--create-ip-pm'){
    options::create_ip_pm();
} elsif ($arg && $arg eq '-h') {
    options::help();
}

my $file_hosts = 'hosts.txt';
my $file_xml = 'disable_ports.xml';

my $rustscan_command = "rustscan";
my $output_file_option = "-a $file_hosts > ip_ports.txt";


my $full_command = "$rustscan_command $config::options $output_file_option";

system($full_command);

my %ports_hash;

open(my $fh, '<', 'ip_ports.txt') or die "The file could not be opened: $!";

while (my $line = <$fh>) {
    chomp $line;
    my ($ip, $ports_str) = split ' -> ', $line;
    $ports_str =~ s/[\[\]]//g;
    my @ports = split ',', $ports_str;

    $ports_hash{$ip} = \@ports;
}

close $fh;

foreach my $key (keys %ip_settings::servers) {
    my @allowed_ports = @{$ip_settings::servers{$key}} if exists $ip_settings::servers{$key};
    my @found_ports = @{$ports_hash{$key}} if exists $ports_hash{$key};

    my @allow_ports;
    my @disable_ports;

    foreach my $port (@found_ports) {
        if (grep { $_ == $port } @allowed_ports) {
            push @allow_ports, $port;
        } else {
            push @disable_ports, $port;
        }
    }

    $log->info("$key, Allowed ports - " . join(", ", @allow_ports)) if @allow_ports;

    if (@disable_ports) {
        $log->info("$key, Prohibited ports - " . join(", ", @disable_ports));

            if ($config::TH){
                my $url = "https://api.telegram.org/bot$config::token/sendMessage";
                my $text = "Problem!!! $key " . join(", ", @disable_ports);

                my $command = qq{curl -s -X POST "$url" -d chat_id="$config::chat_id" -d text="$text"};
                system($command);
            }
        }


    if ($config::blood_moon_mode) {
        my $nmap = "nmap";

        foreach my $port (@disable_ports) {
            my $arguments = "-p T:$port -oX $file_xml";
            my $full_command_nmap = "$nmap $key $arguments";

            system($full_command_nmap);

            my $port_nmap;
            my $service_name;

            my $parser = XML::Parser->new(Handlers => {
                Start => sub {
                    my ($expat, $element, %attrs) = @_;

                    if ($element eq 'port') {
                        $port_nmap = $attrs{portid};
                    } elsif ($element eq 'service') {
                        $service_name = $attrs{name};
                    }
                },
            });

            $parser->parsefile('disable_ports.xml');

            $log->info("$key, NMAP Port: $port_nmap, Service Name: $service_name");
        }
    }
}
