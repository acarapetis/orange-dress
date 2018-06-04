package Replay;
# Replay.pm
# Parses the header of a SpyParty replay

use warnings;
use strict;
require Exporter;
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

our %EXPORT_TAGS = (enums => [
    GAME_RESULT_MISSIONS_WIN,
    GAME_RESULT_SPY_TIMEOUT,
    GAME_RESULT_SPY_SHOT,
    GAME_RESULT_CIVILIAN_SHOT,
    GAME_RESULT_IN_PROGRESS,
    NUM_GAME_RESULTS,
    GAME_TYPE_KNOWN,
    GAME_TYPE_PICK,
    GAME_TYPE_ANY,
    NUM_GAME_TYPES,
    GAME_TYPE_INVALID,
    GAME_TYPE_PACKED_BITS,
    GAME_TYPE_PACKED_SHIFT,

    FLAGS_VERSION_MASK,
    FLAGS_VERSION,
    FLAGS_BEGINNER_MODE,

    REPLAY_FLAG_COMPRESSION_MASK,
    REPLAY_FLAG_COMPRESSION_GZIP,
    REPLAY_FLAG_COMPRESSION_NONE,
]);

# These first 16 bytes will never change
use constant FORMAT_HEAD => [
    ReplayFile4CC => 'a4',
    ReplayFileVersion => 'L',
    P2PProtocolVersion => 'L',
    RevnoVersion => 'L',
];

# The remainder can change due to game updates
use constant FORMAT_TAIL => {
    5 => [
        Flags => 'L',
        Duration => 'f',
        GameID => 'a16',
        StartTime => 'L',
        PlayID => 'S',
        SpyNameLength => 'C',
        SniperNameLength => 'C',
        SpyDisplayNameLength => 'C',
        SniperDisplayNameLength => 'C',
        Unused => 'S',
        FlagsVersion => 'L',
        Result => 'L',
        PackedGameType => 'L',
        MapHash => 'L',
        SelectedMissionsBits => 'L',
        EnabledMissionsBits => 'L',
        AchievedMissionsBits => 'L',
        NumGuests => 'L',
        StartDurationSeconds => 'L',
        ClientLatency => 'f',
        PacketDataSize => 'L',
    ],

    4 => [
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
    ],

    3 => [
        Flags => 'L',
        Duration => 'f',
        GameID => 'a16',
        StartTime => 'L',
        PlayID => 'S',
        SpyNameLength => 'C',
        SniperNameLength => 'C',
        Result => 'L',
        PackedGameType => 'L',
        MapHash => 'L',
        SelectedMissionsBits => 'L',
        EnabledMissionsBits => 'L',
        AchievedMissionsBits => 'L',
        ClientLatency => 'f',
        PacketDataSize => 'L',
    ],
};

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

    my $it = natatime 2, @{+FORMAT_HEAD};
    while (my ($name, $format) = $it->()) {
        read $fh, my $bytes, BYTES->{$format};
        $self->{$name} = unpack($format, $bytes);
    }

    $self->{ReplayFile4CC} eq 'RPLY'
        or die 'Not a SpyParty Replay!';

    my $tail = FORMAT_TAIL->{$self->{ReplayFileVersion}};
    $it = natatime 2, @$tail;
    while (my ($name, $format) = $it->()) {
        read $fh, my $bytes, BYTES->{$format};
        $self->{$name} = unpack($format, $bytes);
    }

    read $fh, my $spyname, $self->{SpyNameLength};
    read $fh, my $snipername, $self->{SniperNameLength};

    read $fh, my $dspyname, $self->{SpyDisplayNameLength} || 0;
    read $fh, my $dsnipername, $self->{SniperDisplayNameLength} || 0;

    $self->{SpyName} = $dspyname || $spyname;
    $self->{SniperName} = $dsnipername || $snipername;

    #UUID::unparse($self->{GameID}, $self->{GameID});

    close $fh;
    bless $self, $class;
}

sub result_winner {
    my $self = shift;
    return 'SPY' if $self->{Result} == GAME_RESULT_MISSIONS_WIN 
        or $self->{Result} == GAME_RESULT_CIVILIAN_SHOT;
    return 'SNIPER' if $self->{Result} == GAME_RESULT_SPY_SHOT
        or $self->{Result} == GAME_RESULT_SPY_TIMEOUT;
    return '';
}

sub winner_name {
    my $self = shift;
    my $result = $self->result_winner();
    return $self->{SpyName} if $result eq 'spy';
    return $self->{SniperName} if $result eq 'sniper';
    return '';
}

1;
