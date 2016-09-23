#!/usr/bin/env bats

setup() {
    echo "Setup"
    export TMP_PATH="/tmp/junit-builder-tests-$(date +%s)"
    if ! [ -e "$TMP_PATH" ]; then
        mkdir -p $TMP_PATH
        #echo "Results in folder $TMP_PATH"
    fi
}

teardown() {
    echo "Teardown"
    rm -rf $TMP_PATH
}

generate_ascii() {
    path=$1
    size=${2:-1M}

    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c$size > $path
}

generate_utf8() {
    path=$1
    size=${2:-1M}

    generate_ascii $path $size

    echo -e '\u2620' >> $path
}

@test "Check that it can be executed without arg" {
    run ./junit_builder
    [ $status = 1 ]
}

@test "Check it can initialize an empty report" {
    run ./junit_builder --file $TMP_PATH/report_init.xml
    [ $status = 0 ]
    [ -e "$TMP_PATH/report_init.xml" ]
}

@test "Check it can update an existing report" {
    cp tests/sample-junit.xml $TMP_PATH/report_update.xml
    run ./junit_builder --file $TMP_PATH/report_update.xml
    [ $status = 0 ]
}

@test "Check it can add a test case to an existing report (stdout)" {
    JUNIT_RESULT_FILE="$TMP_PATH/report_update.xml"

    # Copy existing
    cp tests/sample-junit.xml $JUNIT_RESULT_FILE

    log_file="$TMP_PATH/${BATS_TEST_NUMBER}_stdout.log"
    generate_utf8 $log_file

    run ./junit_builder --file $JUNIT_RESULT_FILE \
                        --testsuite "ts" \
                        --testcase "tc${BATS_TEST_NUMBER}" \
                        --result "failed" \
                        --stdout $log_file
    [ $status = 0 ]
}

@test "Check it can add a test case to an existing report (stdout, stderr)" {
    JUNIT_RESULT_FILE="$TMP_PATH/report_update.xml"

    # Copy existing
    cp tests/sample-junit.xml $JUNIT_RESULT_FILE

    log_file="$TMP_PATH/${BATS_TEST_NUMBER}_stdout.log"
    generate_utf8 $log_file

    log_errors="$TMP_PATH/${BATS_TEST_NUMBER}_stderr.log"
    generate_utf8 $log_errors

    run ./junit_builder --file $JUNIT_RESULT_FILE \
                        --testsuite "ts" \
                        --testcase "tc${BATS_TEST_NUMBER}" \
                        --result "failed" \
                        --stdout $log_file \
                        --stderr $log_errors
    [ $status = 0 ]
}

check_log() {
    log_file=$1
    log_errors=$2
    encoding=$3

    JUNIT_RESULT_FILE="$TMP_PATH/report_update${BATS_TEST_NUMBER}.xml"

    if [ -n "$encoding" ]; then
        encoding_opt="--encoding"
    fi

    run ./junit_builder --file $JUNIT_RESULT_FILE \
                        --testsuite "ts" \
                        --testcase "tc${BATS_TEST_NUMBER}" \
                        --result "failed" \
                        --stdout $log_file \
                        --stderr $log_errors \
                        $encoding_opt $encoding
    [ $status = 0 ]
}

@test "Check with utf8 log" {
    check_log "tests/utf8.log" "tests/utf8.log"
}

@test "Check with stress utf8 log" {
    check_log "tests/utf8-stress.txt" "tests/utf8-stress.txt"
}

@test "Check with log in chinese" {
    check_log "tests/chinese.log" "tests/chinese.log"
}
