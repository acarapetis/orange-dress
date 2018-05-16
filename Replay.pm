package Replay;
# Replay.pm
# Parses the header of a SpyParty replay

use warnings;
use strict;
use List::MoreUtils qw(natatime);
use UUID;

use constant {
    GAME_RESULT_MISSIONS_WIN    => 0,
    GAME_RESULT_SPY_TIMEOUT     => 1,
    GAME_RESULT_SPY_SHOT        => 2,
    GAME_RESULT_CIVILIAN_SHOT   => 3,
    GAME_RESULT_IN_PROGRESS     => 4,
    NUM_GAME_RESULTS            => 5,
    GAME_TYPE_KNOWN             => 0,
    GAME_TYPE_PICK              => 1,
    GAME_TYPE_ANY               => 2,
    NUM_GAME_TYPES              => 3,
    GAME_TYPE_INVALID           => 3,
    GAME_TYPE_PACKED_BITS       => 4,
    GAME_TYPE_PACKED_SHIFT      => 28,

    FLAGS_VERSION_MASK  => 0x0f,
    FLAGS_VERSION       => 0x01,
    FLAGS_BEGINNER_MODE => 0x10,

    REPLAY_FLAG_COMPRESSION_MASK => 0x3,
    REPLAY_FLAG_COMPRESSION_GZIP =>   0,
    REPLAY_FLAG_COMPRESSION_NONE =>   1,
};

use constant FORMAT => [
    ReplayFile4CC => 'a4',
    ReplayFileVersion => 'L',
    P2PProtocolVersion => 'L',
    RevnoVersion => 'L',
    Flags => 'L',
    Duration => 'f',
    GameID => 'a16',
    StartTime => 'L',
    PlayID => 'S',
    SpyNameLength => 'C',
    SniperNameLength => 'C',
    FlagsVersion => 'L',
    Result => 'L',
    PackedGameType => 'L',
    MapHash => 'L',
    SelectedMissionsBits => 'L',
    EnabledMissionsBits => 'L',
    AchievedMissionsBits => 'L',
    ClientLatency => 'f',
    PacketDataSize => 'L',
];

use constant BYTES => {
    a4 => 4,
    a16 => 16,
    L => 4,
    S => 2,
    C => 1,
    f => 4
};

sub from_file {
    my $class = shift;
    my $file = shift;
    my $self = {};
    open my $fh, '<:raw', $file;

    my $it = natatime 2, @{+FORMAT};
    while (my ($name, $format) = $it->()) {
        read $fh, my $bytes, BYTES->{$format};
        $self->{$name} = unpack($format, $bytes);
    }

    read $fh, my $spyname, $self->{SpyNameLength};
    read $fh, my $snipername, $self->{SniperNameLength};

    $self->{SpyName} = $spyname;
    $self->{SniperName} = $snipername;
    UUID::unparse($self->{GameID}, $self->{GameID});

    close $fh;
    bless $self, $class;
}

1;
