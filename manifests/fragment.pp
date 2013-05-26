# == Define: concat::fragment
#
# Puts a file fragment into a directory previous setup using concat
#
# === Options:
#
# [*target*]
#   The file that these fragments belong to
# [*content*]
#   If present puts the content into the file
# [*source*]
#   If content was not specified, use the source
# [*order*]
#   By default all files gets a 10_ prefix in the directory you can set it to
#   anything else using this to influence the order of the content in the file
# [*ensure*]
#   Present/Absent or destination to a file to include another file
# [*mode*]
#   Mode for the file
# [*owner*]
#   Owner of the file
# [*group*]
#   Owner of the file
# [*backup*]
#   Controls the filebucketing behavior of the final file and see File type
#   reference for its use.  Defaults to 'puppet'
#
define concat::fragment(
    $target,
    $content=undef,
    $source=undef,
    $order=10,
    $ensure = 'present',
    $mode = '0644',
    $owner = $::id,
    $group = $concat::setup::root_group,
    $backup = 'puppet') {
    $safe_name = regsubst($name, '[/\n]', '_', 'GM')
    $safe_target_name = regsubst($target, '[/\n]', '_', 'GM')
    $concatdir = $concat::setup::concatdir
    $fragdir = "${concatdir}/${safe_target_name}"

    if $ensure == 'present' {
        if $source == '' and $content == undef {
            fail("One of \$source or \$content must be specified")
        }

        if $source != '' and $content != undef {
            fail("Only one of \$source or \$content must be specified")
        }
    }

    file{"${fragdir}/fragments/${order}_${safe_name}":
        ensure  => $ensure,
        mode    => $mode,
        owner   => $owner,
        group   => $group,
        backup  => $backup,
        alias   => "concat_fragment_${name}",
        notify  => Exec["concat_${target}"]
    }

    if $source {
        File["${fragdir}/fragments/${order}_${safe_name}"] {
            source => $source,
        }
    }
    else {
        File["${fragdir}/fragments/${order}_${safe_name}"] {
            content => $content,
        }
    }
}
