#!/usr/bin/perl

##############################################
##############################################
# Put here your GoEar's username and password:
my $goear_user = "username";
my $goear_pass = "password";
##############################################
##############################################

#
# playgoear.pl
# A Perl Player for GoEar
# (C) Alvaro Marin, <split@splitcc.net>, 24 Jun 2007
#
#
# Redistributable under the terms of the GPL - see
# <http://www.gnu.org/copyleft/gpl.html>
#
# playgoear is a command line interface to access
# to mp3 streams of goear.com without the flash player
# of it's web.
# With playgoear and using the username and password
# of goear.com, you can listen the songs of your
# favorite list on your machine without the web browser
# and you can use the randomly playing mode, continuosly, 
# download them, use the radio...etc.
#
# CHANGELOG:
#
# v1.4	- "r" option in command line mode, plays songs found in Goear with that pattern
#
# v1.3  - reset terminal after Control+C
#	- "s" option in command line mode, is now "i"
#	- "p" option in command line mode, to play the first song found in Goear with that pattern
#	- Fixed problems with searches, introduced in v1.2
#
# v1.2  - Adapted to the new Goear's web.
#	- Removed Radio support
#	- Added "u" option. It seems that Goear updates the MP3's path occasionally...we use this option to update paths
#	- ToDo: playlists
#
# v1.1	- 10 Feb 2010 - adapted to avoid restrictions calling .xml
#	The .xml call is now redirected to: http://www.goear.com/secure_es.mp3
#	Instead of calling the .xml directly, we use http://www.goear.com/hellocalsec.php
#
# v1.0	- Adapted to the new Goear's web.
#	- Stable version released!
#
# v1.0_rc3 - 16 Jun 2009 - Delete songs from your list (rm).
#	Option to add songs from URL.
#
# v1.0_rc2 - 26 May 2009 - Local list...no need of GoEar.com, only to download/listen songs :)
#	There is not need of an username on GoEar.com, only if you want to import your favourite
#	song list. If you have an account, you can import your favourite list from GoEar.com and
#	then, use playgoear to search songs on the web, download them, listen...
#
# v1.0_rc1 - 29 Apr 2009 - Cache for songs. With this feature, the user can cache his songs,
#	so the reproduction will be faster (goear's website sometimes is so slowly...). 
#	Added to the songs table, "localpath" field to store the path to the local song.
#	Previous playgoear's databases are obsolete, but they are in other path, so now worry ;)
#
#	Use "-c" option to cache all your songs (this can take a long time). There are 2 modes:
#
#		This option will download all your favourite list's songs to /home/split/.goear/data.
#		Then you'll listen songs more faster but now, this process can take a while...
#		Now, choose one option:
#		  "a" to abort and exit.
#		  "b" to download all songs in background without interaction and simultaneously.
#		  "r" to download all songs one by one (slower but recomended).
#		Option: 
#
#	The background, "b", mode will open the same "wget"s that the songs that you have added!
#	The "r" mode will download songs one by one (slower but recommended option!)
#
#	Now, when the "d" option is choosed in the menu, the song is downloaded to the
#	cache directory ($HOME/.goear/data/).
#	
#	Added "-i" option to show database's information. For example:
#
#		[+] ID: 66 
#		    Title: Inkomunikazioa - Fermin Muguruza
#		    Goear's path: http://www.goear.com/files/sst4/78678b4a761962f14829c69f217ba4b5.mp3
#		    Local path: /home/split/.goear/data/Inkomunikazioa___Fermin_Muguruza.mp3
#
#		[+] ID: 178 
#		    Title: nortasuna eraikitzen - berri txarrak
# 		    Goear's path: http://www.goear.com/files/mp3files/26102008/840e44d58f99a3d95b2654be621904fa.mp3
#		    Local path: Not Cached! run playgoear.pl with "-c" option or use "d" option of the menu!
#
#	Added some checks, like that mplayer exists.
#
#	Created a directory to save the songs database and the local cache:
#		$HOME/.goear/goear.db for the db
#		$HOME/.goear/data for the local cache
#
# v0.9 - 28 Apr 2009 - Goear's Radio support ("g" option).
#	The .xml just has some mp3 streams, so 	we reproduce them and then, 
#	we get again the .xml. This is an infinite loop  until Ctrl+C! :-/ 
#		ToDo: capture keypresses!
#	The .xml seems to be generated dynamically so sometimes it doesn't exists. We've
#	to try several times.
#
#	New mplayer options added to avoid noise... -nojoystic -nolirc
#
# v0.8 - 27 Apr 2009 - Removed the question about download again the favorite list.
#
#	Added a new menu for the result of the searching option. This will allow:
#		- play randomly through results
#		- play continuosly through results
#		(thx to Raul Moreno for request it)	
#
# v0.7 - 15 Mar 2009 - Support for new URL format
#
# v0.6 - 30 Jan 2009 - Searching on your favourite list feature added!
#
# v0.5 - 12 Jan 2009 - Support for the new locations of the .xml and .mp3 files
#
# v0.4 - 26 Mar 2008 - Added checks to see if required Perl modules are installed
#
# v0.3 - 16 Jul 2007 - Added to mplayer the buffer/cache option to 
#	avoid interrupts when the song is played.
#
#	Added "i" option to see the information of a song:
#
#	Song number to listen or option: i 40
#
#		 Title: Iron Lion Zion - Bob Marley
#		 URL: http://www.goear.com/listen.php?v=f67de6b
#		 MP3: http://www.goear.com/files/sst/ace162817a76f1701daca2a245e4b9ca.mp3
#
# v0.2 - 27 Jun 2007 - Added support to download the mp3 file with
#	"d N" command where "N" is the number of the song.
#	For example:
#
#	...
#	17: I Should Have Known Better - The Skatalites
#	r) Play Randomly
#	c) Play Continuosly
#	d) Download: "d 5" downloads the 5th song
#	             "d ALL" downloads all the favorite list
#	e) Exit
#	Song number to listen or option: d 17
#	Downloading "I Should Have Known Better - The Skatalites" in background...
#
#	This option uses wget command to download it and stores
#	the mp3 file in the directory where playgoear.pl is executed.
#
# v0.1 - 24 Jun 2007 - First release :)
#
#

use Switch;
#use warnings;

# Check if all necesary is installed
eval 'use LWP::UserAgent';
if ($@) {
	print "ERROR: LWP::UserAgent Perl module is required!\n";
	print "Install it executing: \n  perl -MCPAN -e 'install LWP::UserAgent'\n";
	exit;
}
eval 'use HTTP::Request';
if ($@) {
	print "ERROR: HTTP::Request Perl module is required!\n";
	print "Install it executing: \n  perl -MCPAN -e 'install HTTP::Request'\n";
        exit;
}
eval 'use HTTP::Cookies';
if ($@) {
	print "ERROR: HTTP::Cookies Perl module is required!\n";
	print "Install it executing: \n  perl -MCPAN -e 'install HTTP::Cookies'\n";
        exit;
}
eval 'use DBI';
if ($@) {
	print "ERROR: DBI Perl module is required!\n";
	print "Install it executing: \n  perl -MCPAN -e 'install DBI'\n";
        exit;
}
eval 'use DBD::SQLite';
if ($@) {
        print "ERROR: DBD::SQLite Perl module is required!\n";
        print "Install it executing: \n  perl -MCPAN -e 'install DBD::SQLite'\n";
        exit;
}
if ( (! -x "/usr/bin/mplayer") && (! -x "/usr/local/bin/mplayer") && (! -x "/usr/sbin/mplayer")){
	print "ERROR: mplayer not found! Install this program to use playgoear, please.\n";
	exit;
}

# Global vars
my $mplayer="nice -20 mplayer -ao alsa -really-quiet -cache 1024 -cache-min 80 -nojoystick -nolirc ";
my $download="0";
my $cache="0";
my $show="0";
my $command_song="";
my $command_group="";
# Directory for config & cache/data
my $configdir =$ENV{HOME}."/.goear";
# We store the favorite list and the location of each song
my $dbfile = "$configdir/goear.db";
# Cache directory
my $cachedir = "$configdir/data";
my $dbh;
my %songs;


############################### Functions
# Signal interrupts handle
sub interrupt {
	my($signal)=@_;
	print "Ok, now exiting...\n";
	$dbh->disconnect;
	print "Bye bye...\n";
	`reset`;
	exit(1);
}
###############################

foreach $argnum (0 .. $#ARGV) {
	switch ($ARGV[$argnum]) {
	case "-h" {
		print "\nplaygoear.pl - A Perl Player for goear.com - v1.3\n";
		print "  Alvaro Marin, <split\@splitcc.net>, 18 Apr 2012\n\n";
		print "Usage: ./playgoear.pl [-c|-d|-s]\n";
		print "   -c  :  enable song's cache. This'll download Goear's songs to your disk!\n";
		print "   -d  :  download the favorite list using user and password\n";
		print "          configured in the first lines of playgoear.pl.\n";
		print "   -i  :  show database's information.\n";
		print "   -p \"song\" :  play the first song found in Goear with that pattern (use quotes).\n";
		print "   -r \"group\" :  play songs found in Goear with that pattern (use quotes).\n";
		print "playgoear.pl uses mplayer to play the mp3 streams, so install it :)\n\n";
		print "Edit this file and add your username and password for goear.com!\n\n";
		exit;
	}
	case "-c" { $cache = "1";  }
	case "-d" { $download = "1";  }
	case "-s" { $show = "1";  }
	case "-p" { $command_song = $ARGV[1];}
	case "-r" { $command_group = $ARGV[1];}
	}
}

# if command song, just play it!
if (! $command_song && ! $command_group) {

	# Capture signals to close database
	$SIG{'INT' } = 'interrupt';  $SIG{'QUIT'} = 'interrupt';
	$SIG{'HUP' } = 'interrupt';  $SIG{'TRAP'} = 'interrupt';
	$SIG{'ABRT'} = 'interrupt';  $SIG{'STOP'} = 'interrupt';

	# Create directory if not exists
	if ((! -e $configdir) || (! -w $configdir)){
		mkdir $configdir or die("ERROR creating $configdir...\n");
	}
	if ((! -e $cachedir) || (! -w $cachedir)){
		mkdir $cachedir or die("ERROR creating $cachedir...\n");
	}
	
	# Is goear.db file created?
	if ( ! -f "$dbfile"){
		print "Creating $dbfile...from v1.2 of playgoear the .db has another format and path!\n";
		$dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {}) or die("ERROR creating goear.db file. Check permissions or disk space.\n");
		$dbh->do("CREATE TABLE songs (id INTEGER PRIMARY KEY AUTOINCREMENT, goear_id VARCHAR(10), title VARCHAR(200), path varchar(200), localpath varchar(200))");
		print "Good, $dbfile has been created. Connected.\n";
	}
	else {
		$dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {}) or die("ERROR opening goear.db file. Check permissions or disk space.\n");
		print "Good, $dbfile exists. Connected.\n";
	}
}

#################### Handle options from cmd ####################

# DOWNLOAD OPTION
# Connect to Goear.com and download title, path...from the favorite list
if ($download) {
	print "\nWARNING! Your local list will be deleted!\n";
	print "Are you sure (y/n)?: ";
        my $wait=<STDIN>;
	chomp($wait);
	if ("$wait" eq "n"){
		&interrupt;
	}

	print "Connecting to GoEar.com with username \"".$goear_user."\" and downloading the favorite list...\n";

	my $sth = $dbh->prepare("DELETE from songs where 1=1");
	$sth->execute();

	my $goear_url = "http://goear.com/loged.php";
	my $ua = LWP::UserAgent->new;
	$ua->agent("Mozilla/5.0 (X11; U; Linux i686; es-ES; rv:1.9.1.6) Gecko/20100202 Iceweasel/3.5.6 (like Firefox/3.5.6; Debian-3.5.6-2)");
	$ua->default_header('Referer' => "http://www.goear.com");
	$ua->default_header('Host' => 'www.goear.com');
	my $referer = "http://goear.com/login.php";
	$ua->cookie_jar( HTTP::Cookies->new(
	    'file' => '/tmp/cookies.lwp',
	    'autosave' => 1,
	    ));

	my $req = HTTP::Request->new(POST => 'http://goear.com/loged.php');
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("user=$goear_user&pwd=$goear_pass");
	
	my $res = $ua->request($req);

	my $goear_favorites = "http://goear.com/".$goear_user."/favorites_archive/";
	my $response = $ua->get( $goear_favorites );

	if ($response->is_success) {
	  my @lines = split ("\n",$response->content);
	 # $sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (?,?,?,?,?)");
	  foreach (@lines){
#                <a name="song_31d71af"></a><li>
#                  <a href="http://www.goear.com/listen/31d71af/distorsion-la-polla-records">Distorsi&oacute;n - la polla records</a>
#                  <span class="length">3:55</span>
			if ( /listen/){
				my @lines2=split("href",$_);
				foreach (@lines2){
					if ( /listen\/([0-9a-zA-Z]{7})\/[0-9a-zA-Z\-]+\">(.*)\<\/a\>/){
				 	 $goear_id=$1;
					 $goear_title=$2;
					 $url_aux="http://www.goear.com/tracker758.php?f=".$goear_id;
					 $response = $ua->get( "$url_aux");
				         my @lines3 = split ("\n",$response->content);
					 # sanity checks
					 my $sanity_title=$2;
					 $sanity_title=~ s/" - "/" "/g;
					 $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/-/g;
				         foreach (@lines3){
#<songs>
#<song path="http://live3.goear.com/listen/0a408ce6267385e25cbbf437ce489f7b/4f8d88cd/sst3/mp3files/11032007/3027b950f781a9e61fb8b6ac29c84bdb.mp3" bild="http://www.goear.com/1.gif" artist="la polla records" title="Distorsión"/>
#</songs>
				          if ( /path="(.*)" bild=/ ){
						#$path=$1;
						#$path=~/http:\/\/www.goear.com.*\/([a-zA-Z0-9]+\.mp3)/;
						#$sth->execute(NULL,"$goear_id","$goear_title","$1","$cachedir/$sanity_title.mp3");
					        $sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"$goear_id\",\"$goear_title\",\"$1\",\"$cachedir/$sanity_title.mp3\")");
						$sth->execute;
					 	print "Adding song-> ID: $goear_id | TITLE: $goear_title\n";
					  }
					 } 
				        }
			        }
		        }	
	  }
	  $sth->finish;
	}
	else {
	     die $response->status_line;
	}
} 

# CACHE OPTION
# Download songs
if ($cache){
	print "\nThis option will download all your favourite list's songs to $cachedir.\n";
	print "Then you'll listen songs more faster but now, this process can take a while...\n";
        print "Now, choose one option:\n";
	print "  \"a\" to abort and exit.\n";
	print "  \"b\" to download all songs in background without interaction and simultaneously.\n";
	print "  \"r\" to download all songs one by one (slower but recomended).\n";
	print "Option: ";
        my $wait=<STDIN>;
	chomp($wait);
	my $back="";	
	if ("$wait" eq "b") {
		$back="-b";
	}
	elsif ("$wait" eq "r"){
		$back="";
	}
	else {
		$dbh->disconnect;
		exit;
	}
	my $sthc = $dbh->prepare("select * from songs");
	$sthc->execute();
        while ( my ($id,$g_id,$song_title,$song_path,$local_path) = $sthc->fetchrow_array()) {
		if (-e $local_path){
			print "\"$song_title\" already downloaded: $local_path\n";
		}
		else {
	                print "Downloading \"$song_title\" into $local_path...\n";
        	        system("wget $song_path $back -o /dev/null -O \"$local_path\"");
		}
        }

	$sthc->finish;
	$dbh->disconnect;
	exit;
}

# INFORMATION OPTION
# Show database's information and exit
if ($show){
        my $sthi = $dbh->prepare("select * from songs");
        $sthi->execute();
	my $found_r=0;
	print "\nDatabase content:\n";
        while(my ($id,$goear_id,$goear_title,$goear_path,$localpath) = $sthi->fetchrow)
        {
                print "[+] ID: $id \n";
		print "    Title: $goear_title\n";
		print "    Goear's path: $goear_path\n";
		if (-e "$localpath") {
			print "    Local path: $localpath\n";
		}else {
			print "    Local path: Not Cached! run playgoear.pl with \"-c\" option or use \"d\" option of the menu!\n";
		}
		$found_r++;
        }
	print "\n\nTotal: $found_r songs\n";
	$sthi->finish;
	$dbh->disconnect;
	exit;
}

# Command line song
if ($command_song){
	my $ua = LWP::UserAgent->new;
        $ua->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
        $ua->default_header('Referer' => "http://www.goear.com");
        $ua->default_header('Host' => 'www.goear.com');
        $ua->cookie_jar( HTTP::Cookies->new(
           'file' => '/tmp/cookies-cmd.lwp',
           'autosave' => 1,
        ));
	$command_song =~ s/" "/-/g;
	print "Searching for...$command_song...\n";
        my $response = $ua->get( "http://goear.com/search/".$command_song."/" );
        if ($response->is_success) {
	        my @lines = split ("\n",$response->content);
                foreach (@lines){
			if ( / href=\"listen\/([0-9a-zA-Z]{7})\/([0-9a-zA-Z\-]+)"\>\<span class=/){
				my $gid=$1;
				my $gtitle=$2;
				my $url_aux="http://www.goear.com/tracker758.php?f=".$gid;
                                my $ua2 = LWP::UserAgent->new;
               	                $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
				$ua2->default_header('Referer' => "http://www.goear.com");
				$ua2->default_header('Host' => 'www.goear.com');
                       	        my $referer2 = "http://goear.com/login.php";
                               	$ua2->cookie_jar( HTTP::Cookies->new(
	                                   'file' => '/tmp/cookies2.lwp',
                                    'autosave' => 1,
               	                    ));
                                my $response2 = $ua2->get( "$url_aux");
       	                        my @lines2 = split ("\n",$response2->content);
                                foreach (@lines2){
       	                                if ( /path="(.*)" bild=/ ){
						print "Playing (press \"q\" to skip or exit): $gtitle...\n";
						`$mplayer "$1"`;
       						print "Bye bye...\n";
					        exit(1);
					}
				}
			}
		}
	}
}
# Command line group
if ($command_group){
        my $ua = LWP::UserAgent->new;
        $ua->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
        $ua->default_header('Referer' => "http://www.goear.com");
        $ua->default_header('Host' => 'www.goear.com');
        $ua->cookie_jar( HTTP::Cookies->new(
           'file' => '/tmp/cookies-cmd.lwp',
           'autosave' => 1,
        ));
        $command_group =~ s/" "/-/g;
        print "\nSearching for...$command_group...\n";
	my $counter=1;
	my $next=1;
	my %sg_songs;
        print "Searching on page $counter...\n";
	while ($next) {
		$next="0";
	        my $response = $ua->get( "http://goear.com/search/".$command_group."/".$counter );
        	if ($response->is_success) {
			@lines = split ("a title=",$response->content);
			$counter++; # search next page
	                foreach (@lines){
	                        if ( / href=\"listen\/([0-9a-zA-Z]{7})\/([0-9a-zA-Z\-]+)"\>\<span class=/){
							$sg_songs{$song_counter}->{'title'}="$2";
							$sg_songs{$song_counter}->{'g_id'}="$1";
							$song_counter++;
				}
	                        if (/search\/$command_group\/$counter/){
        	                	$next="1";
                                }
                       }
                }
                if ($next){ print "Searching on page $counter...\n"};
      }
	print "No more songs found. Total: $song_counter \n\n";
	for (my $aux=1;$aux<$song_counter;$aux++) {
		my $url_aux="http://www.goear.com/tracker758.php?f=".$sg_songs{$aux}->{'g_id'};
	        my $ua2 = LWP::UserAgent->new;
                $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
		$ua2->default_header('Referer' => "http://www.goear.com");
		$ua2->default_header('Host' => 'www.goear.com');
                my $referer2 = "http://goear.com/login.php";
                $ua2->cookie_jar( HTTP::Cookies->new(
	                       'file' => '/tmp/cookies-cmdg.lwp',
        	               'autosave' => 1,
                ));
                my $response = $ua2->get( "$url_aux");
                my @lines = split ("\n",$response->content);
                # sanity checks
                my $sanity_title=$sg_songs{$aux}->{'title'};
		$sanity_title=~ s/" - "/" "/g;
                $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
                foreach (@lines){
                   	if ( /path="(.*)" bild=/ ){
				print "Playing (press \"q\" to skip or Control+C to exit): ".$sg_songs{$aux}->{'title'}."...\n";
				`$mplayer "$1"`;
			}
		}
	}
	print "Bye bye...\n";
      	exit(1);
}




#################### / Handle options from cmd ####################

# Main LOOP
while (1){

LOOP:;
	my $sth2 = $dbh->prepare("select * from songs");
	$sth2->execute();
	print "\n";
	while(my ($id,$goear_id,$goear_title,$goear_path) = $sth2->fetchrow)
	{
	      	print "$id: ".$goear_title."\n";
	      	if ( ! $songs{$goear_title} ) {
                	$songs{$goear_title}=$goear_path;
        	}
	}
	if (keys(%songs) == 0){
#		print "\nThere are no songs in favorite list. Go to www.goear.com, \n";
#		print "login with your user and password and add some songs to it.\n\n";
#		print "Then, execute \"playgoear.pl -d\" to download it.\n";
		print "\nThere are no songs in your local favorite list. Use the menu to search for your songs on goear.com.\n";			
		print "If you already have an account on goear.com with a favorite list you can import it, using the option \"-d\"\n\n";
#		$dbh->disconnect;
#		exit;
	}
	$sth2->finish();
	print "----\n";
	print "r) Play Randomly\n";
	print "c) Play Continuosly\n";
	print "d) Download: \"d 5\" downloads the 5th song.\n             \"d ALL\" downloads all the favorite list\n";
	print "i) Show song information: \"i 5\"\n";
	print "rm) Remove song from your list: \"rm 5\"\n";
	print "sl) Search on your list:\n             \"sl Berri Txarrak\" searchs for \"Berri Txarrak\" on your list\n";
	print "sg) Search on goear.com for a song:\n             \"sg Berri Txarrak\" searchs for \"Berri Txarrak\"\n";
	print "a) Add a song from URL:\n             \"a http://www.goear.com/listen/4a4bb1d/story-of-my-life-social-distorsion\"\n";
	print "u) Update song's paths (if you can't listen songs from Goear, use this option...Goear changes paths occasionally!)\n";
	print "e) Exit\n";
	print "----\n";
	print "Song number to listen or option: ";
	my $shell=<STDIN>;
	chomp($shell);
 	switch ($shell){
		case /^[Ee]$/ {
			print "\nBye bye...\n";
			$dbh->disconnect;
			exit;
			}
		case /^[0-9]+$/ {
			$sth2 = $dbh->prepare("select title,path,localpath from songs where id=?");
			$sth2->execute($shell);
			my ($song_title,$song_path,$localpath) = $sth2->fetchrow_array();
			$sth2->finish;
			if (-e $localpath){
				print "\n[+] Playing from cache (press \"q\" to skip): ".$shell." - ".$song_title."\n";
				`$mplayer "$localpath"`;
			}
			else {
				print "\n[+] Playing from Goear.com (press \"q\" to skip): ".$shell." - ".$song_title."\n";
				`$mplayer "$song_path"`;
			}
		}
		case /^[Rr]$/ {
			print "\nPlaying Randomly (press \"Ctrl+c\" to exit)...\n";
			#foreach $song ( keys(%songs) ){
			#	print "SONG: $song ->  ".$songs{$song}."\n";
			#}
			my @keys = keys %songs;
			while (1){
				$random=$keys[int(rand(keys(%songs)))];
				$sth2 = $dbh->prepare("select path,localpath from songs where path=?");
				$sth2->execute("$songs{$random}");
				my ($song_path,$localpath) = $sth2->fetchrow_array();
				$sth2->finish;
				if (-e $localpath){
					print "[+] Playing from cache (press \"q\" to skip): ".$random."\n";
					`$mplayer "$localpath"`;
				}
				else {
					print "[+] Playing from Goear.com (press \"q\" to skip): ".$random."\n";	
					`$mplayer "$songs{$random}"`;
				}	
			}
		}
		case /^[Cc]$/ {
			print "\nPlay Continuosly (press \"Ctrl+c\" to exit)...\n";
			while (1){
				$sth2 = $dbh->prepare("select title,path,localpath from songs");
			        $sth2->execute();
			        while( ($goear_title,$goear_path,$localpath) = $sth2->fetchrow)
			        {
		                        if (-e $localpath){
                		                print "[+] Playing from cache (press \"q\" to skip): $song_title\n";
                                		`$mplayer "$localpath"`;
		                        }
                		        else {
                                		print "[+] Playing from Goear.com (press \"q\" to skip): $song_title\n";
		                                `$mplayer "$goear_path"`;
                		        }
				}
                                $sth2->finish;
			}
		}
		case /^rm ([0-9]+)$/ {
			$shell =~ /^rm ([0-9]+)$/;
			my $aux=$1;
			if ($1=~/[0-9]+/){
				$sth2 = $dbh->prepare("delete from songs where id=?");
				$sth2->execute($aux);
				$sth2->finish;
			}
		}
		case /^[Dd] ([0-9]+|ALL)$/ {
			$shell =~ /^[Dd] (([0-9]+|ALL))$/;
			my $aux=$1;
			if ($1=~/[0-9]+/){
	                        $sth2 = $dbh->prepare("select title,path,localpath from songs where id=?");
        	                $sth2->execute($aux);
                	        my ($song_title,$song_path,$localpath) = $sth2->fetchrow_array();
				print "\nDownloading \"$song_title\" in background to $localpath...\n\n";
				`wget $song_path -b --quiet -o /dev/null -O \"$localpath\"`;
                        	$sth2->finish;	
				print "Press ENTER to continue...\n";
				my $wait=<STDIN>;
			}
			elsif ($1 eq "ALL"){
                                $sth2 = $dbh->prepare("select title,path,localpath from songs");
                                $sth2->execute();
				print "\n";
                                while ( ($song_title,$song_path,$localpath) = $sth2->fetchrow_array()) {
					print "Downloading \"$song_title\" in background to $localpath...\n";
	                                `wget $song_path -b --quiet -o /dev/null -O \"$localpath\"`;
				}
				print "\n";
				print "Press ENTER to continue...\n";
				my $wait=<STDIN>;
                                $sth2->finish;
			}
		}
		case /^[iI] ([0-9]+)$/ {
			$shell =~ /^[iI] ([0-9]+)$/;
			$sth2 = $dbh->prepare("select goear_id,title,path,localpath from songs where id=?");
			$sth2->execute($1);
			($goear_id,$song_title,$song_path,$localpath) = $sth2->fetchrow_array();
			print "\n\n Title: $song_title\n";
			$song_title=~ s/\s/-/g;
			print " URL: http://goear.com/listen/$goear_id/$song_title\n";
			print " MP3: $song_path\n";
			if (-e $localpath){
				print " Local: $localpath\n";
			}
			print "\nPress ENTER to continue...\n";
			my $wait=<STDIN>;
		}
		case /^[sS][lL] [a-zA-Z0-9]{1,}(\s*[a-zA-Z0-9\-]{0,}){0,}$/ {
			# spaces, numbers or word characters
			$shell =~ /^[sS][lL] ([a-zA-Z0-9\-]{1,}(\s*[a-zA-Z0-9\-]{0,}){0,})/;
			print "\nSearching for...$1...\n\n";
			$sth2 = $dbh->prepare("select id,title from songs where title like \"%"."$1"."%\"");
			$sth2->execute();
			my $found=0;
			while ( ($id,$song_title) = $sth2->fetchrow_array() ) {
				if ($id) {
					print "$id: $song_title\n";
					$found=1;	
				}
			}
			if ($found==1){
SUBSET:;
				print "----\n";
			        print "r) Play Randomly this set\n";
			        print "c) Play Continuosly this set\n";
			        print "e) Exit and return to the previous menu\n";
				print "----\n";
				print "Song number to listen or option: ";
				my $set=<STDIN>;
			        chomp($set);
				print "\n";
			        switch ($set){
			                case /^[Rr]$/ {
                        			print "Playing Randomly (press \"Ctrl+c\" to exit)...\n";
						$sth2 = $dbh->prepare("select goear_id,title,path,localpath from songs where title like \"%"."$1"."%\"");
						$sth2->execute();
			                        my %songs_set;
                        			while(my ($goear_id,$goear_title,$goear_path,$localpath) = $sth2->fetchrow)
			                        {
			                                if ( ! $songs_set{$goear_title} ) {
								if (-e $localpath){
				                                        $songs_set{$goear_title}=$localpath;
								}
								else {
				                                        $songs_set{$goear_title}=$goear_path;
								}
			                                }
			                        }

			                        my @keys_set = keys %songs_set;
			                        while (1){
			                                $random=$keys_set[int(rand(keys(%songs_set)))];
				                        print "[+] Playing (press \"q\" to skip): ".$random."\n";
                                			`mplayer "$songs_set{$random}"`;
				                }
						$sth2->finish;
						goto SUBSET;
					}
					case /^[Cc]$/ {
						print "\nPlay Continuosly (press \"Ctrl+c\" to exit)...\n";
						$sth2 = $dbh->prepare("select goear_id,title,path from songs where title like \"%"."$1"."%\"");
						$sth2->execute();
        	                        	while( ($goear_id,$goear_title,$goear_path,$localpath) = $sth2->fetchrow)
	                	                {
							if (-e $localpath){
	                                                	print "[+] Playing from cache (press \"q\" to skip): $song_title\n";
        		                                        `$mplayer "$localpath"`;
                        		                }
                                        		else {
		                                                print "[+] Playing from Goear.com (press \"q\" to skip): $song_title\n";
                		                                `$mplayer "$goear_path"`;
                                		        }
			
	                	                }
        	                	        $sth2->finish;
						goto SUBSET;
					}
			                case /^[Ee]$/ {
                        			print "\nReturning to main menu...\n";
						goto LOOP;
                        		}
			                case /^[0-9]+$/ {
                        			$sth2 = $dbh->prepare("select title,path,localpath from songs where id=?");
			                        $sth2->execute($set);
                        			my ($song_title,$song_path,$local_path) = $sth2->fetchrow_array();
			                        $sth2->finish;
						if (-e $local_path){ 
				                        print "[+] Playing from cache (press \"q\" to skip): ".$set." - ".$song_title."\n";
				                        `$mplayer "$local_path"`;
						}
						else {
							print "[+] Playing from Goear.com (press \"q\" to skip): ".$set." - ".$song_title."\n";
                                                        `$mplayer "$song_path"`;
						}
						goto SUBSET;
			                }
				}
			}
			else {
				print "\nNothing found :(\n";
				my $wait=<STDIN>;
			}
			$sth2->finish;
		}
		case /^[sS][gG] [a-zA-Z0-9]{1,}(\s*[a-zA-Z0-9\-]{0,}){0,}$/ {
                        # spaces, numbers or word characters
                        $shell =~ /^[sS][gG] ([a-zA-Z0-9\-]{1,}(\s*[a-zA-Z0-9\-]{0,}){0,})/;
			my $token=$1;
                        print "\nSearching for...$token...\n\n";
			$token =~ s/" "/-/g;
			# http://goear.com/search/berri-txarrak/
                        my $ua3 = LWP::UserAgent->new;
                        $ua3->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
			$ua3->default_header('Referer' => "http://www.goear.com");
			$ua3->default_header('Host' => 'www.goear.com');
			$ua3->cookie_jar( HTTP::Cookies->new(
                            'file' => '/tmp/cookies3.lwp',
                            'autosave' => 1,
                            ));
			my $next="1";
			my $counter=0; # for next pages
			my $song_counter="1";
			my $response3;
			my %sg_songs;
			while ($next) {
				$next="0";
				my $url_search_aux;
	                        $response3 = $ua3->get( "http://goear.com/search/".$token."/".$counter );
        	                if ($response3->is_success) {
                        	        #@lines = split ("title=\"Listen\"",$response3->content);
                        	        @lines = split ("a title=",$response3->content);
					$counter++; # search next page
                                	foreach (@lines){
#  <li ><a title="Escuchar Bueltatzen - berri txarrak" href="listen/2b00e94/bueltatzen-berri-txarrak"><span class="song">Bueltatzen</span> - <span class="group">berri txarrak</span></a><a class="play" lang="en" xml:lang="en" title="Escuchar en una ventana independiente" onclick="window.open('http://www.goear.com/listen_popup.php?v=2b00e94','','width=800,height=450,resizable=yes')" href="javascript:void(0);"><img alt="Play" src="http://www.goear.com/lib/img/popup.png" /></a><p class="comment">berri txarrakren abesti bat</p><span class="length">3:24</span></li><li class="even"><a title="Escuchar Ez - berri txarrak" href="listen/50bbd9b/ez-berri-txarrak"><span class="song">Ez</span> - <span class="group">berri txarrak</span></a><a class="play" lang="en" xml:lang="en" title="Escuchar en una ventana independiente" onclick="window.open('http://www.goear.com/listen_popup.php?v=50bbd9b','','width=800,height=450,resizable=yes')" href="javascript:void(0);"><img alt="Play" src="http://www.goear.com/lib/img/popup.png" /></a>
	                                        #if ( /\<a title=\"Escuchar (.*)\" href=\"listen\/([0-9a-zA-Z]{7})\/.*"\>\<span class=/){
	                                        if ( / href=\"listen\/([0-9a-zA-Z]{7})\/([0-9a-zA-Z\-]+)"\>\<span class=/){
       # 	                                        print "$1 - $2\n";
							# 1 -> "Bueltatzen - Berri Txarrak","2b00e94"
							# Add new element to the hash
							$sg_songs{$song_counter}->{'title'}="$2";
							$sg_songs{$song_counter}->{'g_id'}="$1";
							$song_counter++;
                	                        }
						#elsif (/<a href=\'search\.php\?q=.*&p=[0-9]{1,}\'>Next.*/){
						if (/search\/$token\/$counter/){
							$next="1";
						}
                        	        }
				 }
				if ($next){ print "Searching on page $counter...\n"};
			}
			print "\nNo more songs found. Total: $song_counter \n";
			for (my $aux=1;$aux<$song_counter;$aux++) {
				print "$aux : ".$sg_songs{$aux}->{'title'}."\n";
			}
			print "You can select now the songs to add to your local list.\n";
			print "Examples:\n";
			print " \"4\" adds to your list song number 4\n";
			print " \"4,9,16\" adds to your list songs number 4, number 9 and number 16\n";
			print " \"4-12\" adds to your list songs number 4,5,6,7,8,9,10,11 and 12\n";
			print " \"ALL\" adds to your list all songs found\n";
			print "Or press \"e\" to return...\n";
			print "Option: ";
			my $option=<STDIN>;
			chomp($option);
			if ($option=~/^[0-9]+$/) {
                                #my $url_aux="http://goear.com/files/xmlfiles/$first/secm".$sg_songs{$option}->{'g_id'}.".xml";
				my $url_aux="http://www.goear.com/tracker758.php?f=".$sg_songs{$option}->{'g_id'};
	                        my $ua2 = LWP::UserAgent->new;
        	                $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
				$ua2->default_header('Referer' => "http://www.goear.com");
				$ua2->default_header('Host' => 'www.goear.com');
                	        my $referer2 = "http://goear.com/login.php";
                        	$ua2->cookie_jar( HTTP::Cookies->new(
	                            'file' => '/tmp/cookies2.lwp',
        	                    'autosave' => 1,
                	            ));

                                my $response = $ua2->get( "$url_aux");
                                my @lines = split ("\n",$response->content);
                                # sanity checks
                                my $sanity_title=$sg_songs{$option}->{'title'};
				$sanity_title=~ s/" - "/" "/g;
                                $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
                                foreach (@lines){
                                	if ( /path="(.*)" bild=/ ){
						# NULL for AUTOINCREMENT only runs doing this without "?"
	  					$sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"".$sg_songs{$option}->{'g_id'}."\",\"".$sg_songs{$option}->{'title'}."\",\"$1\",\"$cachedir/$sanity_title.mp3\")");
						$sth->execute();
						$sth->finish;
                                          }
                                }
			} elsif ($option=~/^[0-9]+,[0-9]+(,[0-9]+)*/) {
				my @songs_opt=split(",",$option);
				foreach my $s (@songs_opt){
	                                #my $url_aux="http://goear.com/files/xmlfiles/$first/secm".$sg_songs{$s}->{'g_id'}.".xml";
					my $url_aux="http://www.goear.com/tracker758.php?f=".$sg_songs{$option}->{'g_id'};
        	                        my $ua2 = LWP::UserAgent->new;
                	                $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
					$ua2->default_header('Referer' => "http://www.goear.com");
					$ua2->default_header('Host' => 'www.goear.com');
                        	        my $referer2 = "http://goear.com/login.php";
                                	$ua2->cookie_jar( HTTP::Cookies->new(
	                                    'file' => '/tmp/cookies2.lwp',
        	                            'autosave' => 1,
                	                    ));

	                                my $response = $ua2->get( "$url_aux");
        	                        my @lines = split ("\n",$response->content);
                	                # sanity checks
                        	        my $sanity_title=$sg_songs{$s}->{'title'};
					$sanity_title=~ s/" - "/" "/g;
	                                $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
        	                        foreach (@lines){
                	                        if ( /path="(.*)" bild=/ ){
                        	                        # NULL for AUTOINCREMENT only runs doing this without "?"
                                	                $sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"".$sg_songs{$s}->{'g_id'}."\",\"".$sg_songs{$s}->{'title'}."\",\"$1\",\"$cachedir/$sanity_title.mp3\")");
                                        	        $sth->execute();
                                                	$sth->finish;
	                                          }
        	                        }
	
				}
			}
			elsif ($option=~/^([0-9]+)-([0-9]+)$/) {
				my $init=$1;
				my $last=$2;
				for (my $aux=$init;$aux<=$last;$aux++){
	                                my $first=substr($sg_songs{$aux}->{'g_id'},0,1);
        	                        #my $url_aux="http://goear.com/files/xmlfiles/$first/secm".$sg_songs{$aux}->{'g_id'}.".xml";
					my $url_aux="http://www.goear.com/tracker758.php?f=".$sg_songs{$option}->{'g_id'};
                	                my $ua2 = LWP::UserAgent->new;
                        	        $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
					$ua2->default_header('Referer' => "http://www.goear.com");
					$ua2->default_header('Host' => 'www.goear.com');
                                	my $referer2 = "http://goear.com/login.php";
	                                $ua2->cookie_jar( HTTP::Cookies->new(
        	                            'file' => '/tmp/cookies2.lwp',
                	                    'autosave' => 1,
                        	            ));

	                                my $response = $ua2->get( "$url_aux");
        	                        my @lines = split ("\n",$response->content);
                	                # sanity checks
                        	        my $sanity_title=$sg_songs{$aux}->{'title'};
					$sanity_title=~ s/" - "/" "/g;
                                	$sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
	                                foreach (@lines){
        	                                if ( /path="(.*)" bild=/ ){
                	                                # NULL for AUTOINCREMENT only runs doing this without "?"
                        	                        $sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"".$sg_songs{$aux}->{'g_id'}."\",\"".$sg_songs{$aux}->{'title'}."\",\"$1\",\"$cachedir/$sanity_title.mp3\")");
	                                                $sth->execute();
        	                                        $sth->finish;
                	                          }
                        	        }
				}
			}
			elsif ($option=~/^ALL$/) {
				my $hash_size=scalar keys %$sg_songs;
				for (my $aux=0;$aux<=$hash_size;$aux++){
                                        #my $url_aux="http://goear.com/files/xmlfiles/$first/secm".$sg_songs{$aux}->{'g_id'}.".xml";
					my $url_aux="http://www.goear.com/tracker758.php?f=".$sg_songs{$option}->{'g_id'};
                                        my $ua2 = LWP::UserAgent->new;
                                        $ua2->agent("Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.4)");
					$ua2->default_header('Referer' => "http://www.goear.com");
					$ua2->default_header('Host' => 'www.goear.com');
                                        my $referer2 = "http://goear.com/login.php";
                                        $ua2->cookie_jar( HTTP::Cookies->new(
                                            'file' => '/tmp/cookies2.lwp',
                                            'autosave' => 1,
                                            ));

                                        my $response = $ua2->get( "$url_aux");
                                        my @lines = split ("\n",$response->content);
                                        # sanity checks
                                        my $sanity_title=$sg_songs{$aux}->{'title'};
					$sanity_title=~ s/" - "/" "/g;
                                        $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
                                        foreach (@lines){
                                                if ( /path="(.*)" bild=/ ){
                                                        # NULL for AUTOINCREMENT only runs doing this without "?"
                                                        $sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"".$sg_songs{$aux}->{'g_id'}."\",\"".$sg_songs{$aux}->{'title'}."\",\"$1\",\"$cachedir/$sanity_title.mp3\")");
                                                        $sth->execute();
                                                        $sth->finish;
                                                  }
                                        }
					
				}
			}
		} # case
		case /^a .*$/ {
			$shell =~ /^a (.*)$/;
		        my $ua = LWP::UserAgent->new;
		        $ua->agent("Mozilla/5.0 (X11; U; Linux i686; es-ES; rv:1.9.1.6) Gecko/20100202 Iceweasel/3.5.6 (like Firefox/3.5.6; Debian-3.5.6-2)");
			$ua->default_header('Referer' => "http://www.goear.com");
			$ua->default_header('Host' => 'www.goear.com');

		        my $response = $ua->get( $1 );

		        if ($response->is_success) {
		          my @lines = split ("\n",$response->content);
		          foreach (@lines){
                	        if ( /localplayer/){
                        	        my @lines2=split("href",$_);
                                	foreach (@lines2){
						# title="Listen" alt="Listen" /> story of my life (<a class="normal" href="listenwin.php?v=4a4bb1d"
                                        	#if ( /\"listenwin\.php\?v=([0-9a-zA-Z]{7})\"/){
						# <embed src="http://www.goear.com/files/local.swf?file=47ebca4" type=
                                        	if ( /\/localplayer\.swf\?file=([0-9a-zA-Z]{7})\"/){
						 my $goear_id=$1;
#        	                                 $url_aux="http://goear.com/files/xmlfiles/$first/secm$1.xml";
						$url_aux="http://www.goear.com/tracker758.php?f=".$goear_id;
                	                         $response = $ua->get( "$url_aux");
                        	                 @lines = split ("\n",$response->content);
                                	         foreach (@lines){
                                        	  if ( /path=\"(.*)\" bild=\".*\" artist=\"(.*)\".*title=\"(.*)\"/ ){
	                                                $path=$1;
							my $title=sprintf("%s - %s",$3,$2);
        	                                        $path=~/http:\/\/www.goear.com.*\/([a-zA-Z0-9]+\.mp3)/;
        	                                 	# sanity checks
                	                         	my $sanity_title=$title;
        	                	                $sanity_title=~ s/(\s|-|\/|\\|\$|%|')/_/g;
                        	                        my $sth;
							$sth = $dbh->prepare("INSERT INTO songs (id,goear_id,title,path,localpath) values (NULL,\"$goear_id\",\"$title\",\"$path\",\"$cachedir/$sanity_title.mp3\")");
	                               	                $sth->execute;
	                               	                $sth->finish;
                                        	  }
	                                         }
        	                                }
                	                }
                        	}
	          }
	        }
        	else {
	             die $response->status_line;
	        }
			
		
                } # case
                case /^[uU]$/ {
                        $sth = $dbh->prepare("select goear_id,title from songs");
                        $sth->execute();
                        while ( my ($goear_id,$title) = $sth->fetchrow_array() ) {
		                        my $ua = LWP::UserAgent->new;
                		        $ua->agent("Mozilla/5.0 (X11; U; Linux i686; es-ES; rv:1.9.1.6) Gecko/20100202 Iceweasel/3.5.6 (like Firefox/3.5.6; Debian-3.5.6-2)");
		                        $ua->default_header('Referer' => "http://www.goear.com");
		                        $ua->default_header('Host' => 'www.goear.com');
					$url_aux="http://www.goear.com/tracker758.php?f=".$goear_id;
		                        my $response = $ua->get( $url_aux );
		                        if ($response->is_success) {
                                       		my @lines3 = split ("\n",$response->content);
                                       		foreach (@lines3){
                                                  if ( /path=\"(.*)\" bild=/ ){
                                                        my $path=$1;
                                                        my $sth2;
                                                        $sth2 = $dbh->prepare("update songs set path=\"".$path."\" where goear_id=\"".$goear_id."\";");
                                                        $sth2->execute;
                                                        $sth2->finish;
                                       			print "Updating path of $goear_id: $title\n";
                                                  }
						}
					}
                        }
			$sth->finish;
		}
		else { 
			print "\nBad option...press ENTER.\n";
			my $wait=<STDIN>;
		}
	}

}

$dbh->disconnect;
exit; 
