#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2024 Olliver Schinagl <oliver@schinagl.nl>

set -eu

_msg()
{
	_level="${1:?Missing argument to function}"
	shift

	if [ "${#}" -le 0 ]; then
		echo "${_level}: No content for this message ..."
		return
	fi

	echo "${_level}: ${*}"
}

e_err()
{
	_msg 'err' "${*}" >&2
}

usage()
{
	echo "Usage: ${0}"
	echo 'Helper script to bump the target kernel version, whilst keeping history.'
	echo '    -c  Migrate config files (e.g. subtargets) only.'
	echo "    -p  Optional Platform name (e.g. 'ath79' [PLATFORM_NAME]"
	echo "    -r  Optional comma separated list of sub-targets (e.g. 'rtl930x' [SUBTARGET_NAMES]"
	echo "    -s  Source version of kernel (e.g. 'v6.1' [SOURCE_VERSION])"
	echo "    -t  Target version of kernel (e.g. 'v6.6' [TARGET_VERSION]')"
	echo
	echo 'All options can also be passed in environment variables (listed between [BRACKETS]).'
	echo 'Note that this script must be run from within the OpenWrt git repository.'
	echo 'Example: scripts/kernel_bump.sh -p realtek -s v6.1 -t v6.6'
}

main()
{
	while getopts 'chp:r:s:t:' _options; do
		case "${_options}" in
		'c')
			config_only='true'
			;;
		'h')
			usage
			exit 0
			;;
		'p')
			platform_name="${OPTARG}"
			;;
		'r')
			subtarget_names="${OPTARG}"
			;;
		's')
			source_version="${OPTARG}"
			;;
		't')
			target_version="${OPTARG}"
			;;
		':')
			e_err "Option -${OPTARG} requires an argument."
			exit 1
			;;
		*)
			e_err "Invalid option: -${OPTARG}"
			exit 1
			;;
		esac
	done
	shift "$((OPTIND - 1))"

	platform_name="${platform_name:-${PLATFORM_NAME:-}}"
	subtarget_names="${subtarget_names:-${SUBTARGET_NAMES:-}}"
	source_version="${source_version:-${SOURCE_VERSION:-}}"
	target_version="${target_version:-${TARGET_VERSION:-}}"

	if [ -z "${source_version:-}" ] || [ -z "${target_version:-}" ]; then
		e_err "Source (${source_version:-missing source version}) and target (${target_version:-missing target version}) versions need to be defined."
		echo
		usage
		exit 1
	fi

	if [ -z "${platform_name}" ] || \
	   [ -d "${PWD}/image" ]; then
		platform_name="${PWD}"
	fi
	platform_name="${platform_name##*'/'}"

	_target_dir="${src_dir}/../target/linux/${platform_name}"

	if [ ! -d "${_target_dir}/image" ]; then
		e_err "Cannot find target linux directory '${_target_dir:-not defined}'. Not in a platform directory, or -p not set."
		exit 1
	fi

	source_version="-$source_version"
	target_version="-$target_version"

	if [ -n "${config_only:-}" ]; then
		source_version="/config$source_version"
		target_version="/config$target_version"
	fi

	exec "${0%${0##*/}}kernel_upgrade.pl" "$source_version" "$target_version" "$platform_name"
}

main "${@}"

exit 0
