#!/bin/sh

export buildpack=$(dirname $(dirname $0))
BUILDPACK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

install_python() {
    cache=$(cd "$1/" && pwd)
    export PYTHONHOME=$cache/python
    export PATH=$PYTHONHOME/bin:$PATH

    if test -d $PYTHONHOME
    then
        echo "-----> Python 2.7.6 already installed"
    else
        echo -n "-----> Installing Python 2.7.6..."
        $buildpack/builds/runtimes/python-2.7.6 $PYTHONHOME > /dev/null 2>&1
        mv $PYTHONHOME/bin/python2.7 $PYTHONHOME/bin/python
        echo "done"
    fi
}

if test -d $BUILDPACK_PATH/dependencies
then
    notice_inline 'Use locally cached dependencies where possible'

    function curl() {
        local write_file=''

        ## Split the arguments from curl command into an array
        IFS=' ' read -a curl_args <<< "$@"

        ## Iterate over each arg until we find one that starts with http
        local count=0
        for arg in "${curl_args[@]}"
        do
            ## Does the argument start with http?
            if [[ $arg == http* ]]
            then
                filename=$(sed 's/[:\/]/_/g' <<< ${arg})
            fi

            ## Does the argument have an output file?
            if [[ $arg == '-o' ]]
            then
                write_file=${curl_args[count+1]}
            fi

            # Increment counter
            let count+=1
        done

        if test -f $BUILDPACK_PATH/dependencies/$filename
        then
            ## Was a file to write to provided?
            if [[ -n "$write_file" ]]
            then
                ## Write to file
                cat $BUILDPACK_PATH/dependencies/$filename > $write_file
            else
                # Stream output
                cat $BUILDPACK_PATH/dependencies/$filename
            fi
        else
            echo "Expected dependency to exist but could not find it: ${1}" 1>&2
        fi
    }
fi


