package options;

use strict;
use warnings;
use config;


sub help {
 my $help = <<END_MESSAGE;
    --create-ip-list Creates a file with ip addresses from ip.pm.
    --create-ip-pm   The --create-ip-pm parameter is used to create ip.pm with already entered ip addresses and allowed ports.
                     The input of IP addresses from RustScan is supported. Usage example:
                     eclipse.pl --create-ip-pm 192.168.1.1 or eclipse.pl --create-ip-pm 192.168.1.1,192.168.1.2
END_MESSAGE
    print($help);
    exit 1;       
}

sub create_ip_pm {
    my $ip_address = shift @ARGV;
    
    unless ($ip_address) {
        die "The IP address is not specified. Usage example: --create-ip-pm 192.168.1.1\n";
    }

    my $rustscan_command = "rustscan";
    my $output_file_option = "-a $ip_address > ip_ports_pm.txt";
    my $full_command = "$rustscan_command $config::options $output_file_option";

    system($full_command);

    my %ip_ports_hash_pm;

    open(my $fh, '<', 'ip_ports_pm.txt') or die "The file could not be opened: $!";

    while (my $line = <$fh>) {
        chomp $line;
        my ($ip, $ports_str) = split ' -> ', $line;
        $ports_str =~ s/[\[\]]//g;
        my @ports = split ',', $ports_str;

        $ip_ports_hash_pm{$ip} = \@ports;
    }

    close $fh;

    open  $fh, '>', 'ip.pm' or die "I can't open the file: $!";
    print $fh "package ip_settings;\n\nour %servers = (\n";

    foreach my $key (keys %ip_ports_hash_pm) {
        my $ports = join ", ", @{$ip_ports_hash_pm{$key}};
        print $fh "    '$key' => [$ports],\n";
    }

    print $fh ");\n\n1;\n";

    close $fh;

    print  "IP addresses and open ports have been added to ip.pm\n";
    exit 1;
}

sub create_list {
    my @keys = sort { $a cmp $b } keys %ip_settings::servers;
    my $file = 'hosts.txt';

    if (-e $file) {
        print "Overwriting the file...\n";
    }

    open(my $fh, '>', $file) or die "Could not open the '$file' for writing: $!";

    foreach my $element (@keys) {
        print $fh "$element\n" or die "Failed to write to a file: $!";
    }

    close $fh;

    print "The file with ip addresses has been successfully created '$file'\n";
    exit 1;
}

1;
