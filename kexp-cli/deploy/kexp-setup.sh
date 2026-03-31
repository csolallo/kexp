#!/usr/bin/env bash

# $1 : verbose flag
function prepare_app_build() {
    local verbose="$1"

    dart pub get
    
    pushd ./kexp-cli > /dev/null
    rm -rf .dart_tool
    rm pubspec.*
    rm ./lib/kexp_api/pubspec.yaml

    popd > /dev/null

    create_driver_script "$verbose"
}

# $1 : verbose flag
function create_driver_script() {
    local verbose="$1"

    sc=$(cat <<EOF
#!/data/data/com.termux/files/usr/bin/bash

pushd ~/.termux/tasker/kexp-cli > /dev/null    
dart bin/kexp_cli.dart plays -n 1
popd > /dev/null
EOF
)
    if [ "$verbose" == "1" ]; then
        echo "$sc"
    fi

    echo "$sc" > kexp_plays.sh
    chmod +x kexp_plays.sh
}

# $1 : working folder
# $2 : destination folder
function move_app_to_destination() {
    local working="$1"
    local dest="$2"

    mkdir -p $dest/kexp-cli && cp -a $working/kexp-cli/. $dest/kexp-cli
    cp $working/kexp_plays.sh $dest/kexp_plays.sh
}

export -f prepare_app_build
export -f move_app_to_destination
