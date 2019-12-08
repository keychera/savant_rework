
source runconfig

CLASSES_TO_CMPL=$(find ./src/ -name "*.java")
mkdir -p target
$JAVAC7_PATH -cp "./lib/*" -d "./target/" $CLASSES_TO_CMPL

CLS_DIR=$(defects4j export -p dir.bin.classes -w $TARGETPROJECT)
TEST_DIR=$(defects4j export -p dir.bin.tests -w $TARGETPROJECT)

CLASS_PATHS="$TARGETPROJECT/$CLS_DIR:$TARGETPROJECT/$TEST_DIR:./lib/*:./target"
SINGLETESTRUN="$JAVA7_PATH -cp "$CLASS_PATHS" SingleTestRunner"

#should fail
$SINGLETESTRUN org.apache.commons.lang3.math.NumberUtilsTest::TestLang747

#should pass
$SINGLETESTRUN org.apache.commons.lang3.AnnotationUtilsTest::testBothArgsNull

#should pass
$SINGLETESTRUN org.apache.commons.lang3.LocaleUtilsTest::testParseAllLocales