junit-builder
=============

![Travis](https://img.shields.io/travis/CoRfr/junit-builder.svg)

A simple python script to build JUnit test reports through command line.

Install
-------

```bash
pip install -r requirements.txt
sudo cp junit_builder /usr/local/bin
```

Example
-------

```bash
# Init report
junit_builder --file report.xml

# Run test case
... > tc_stdout.log 2> tc_stderr.log
if [ $? -eq 0 ]; then
    result="passed"
else
    result="failed"
fi

# Update report
./junit_builder --file report.xml \
                --testsuite "myTestSuite" \
                --testcase "myTestCase42" \
                --result "$result" \
                --stdout "tc_stdout.log" \
                --stderr "tc_stderr.log"
```
