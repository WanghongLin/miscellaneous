#!/bin/bash
# Migrate Android Eclipse Project to Android Studio
# Copyright 2016 Wanghong Lin 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# 	http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# TODO: add jni support
# 
__ScriptVersion="v0.01"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	echo "Usage :  $0 [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -s|sdk        Android SDK root
    -f|from       From Eclipse project
    -t|to         To Android studio project
    -n|name       Destination project name"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

_AndroidSdkRoot=$ANDROID_SDK_ROOT
_From=
_To=
_Name=

while getopts ":hvs:f:t:n:" opt
do
  case $opt in

	h|help     )  usage; exit 0   ;;

	v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

	s|sdk      )  _AndroidSdkRoot=$OPTARG ;;

	f|from     )  _From=$OPTARG ;;

	t|to       )  _To=$OPTARG ;;
	
	n|name     )  _Name=$OPTARG ;;

	* )  echo -e "\n  Option does not exist : $OPTARG\n"
		  usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

[ x"$_AndroidSdkRoot" == x ] && {
    printf '\e[31mANDROID_SDK_ROOT not set\e[30m\n'
	usage
	exit 1
}

if [[ x$_From == x || x$_To == x || x$_Name == x ]];then
	usage
	exit 1
fi

printf "======================================================\n"
printf "Migrate from\t $_From ===> $_To\n"
printf "Android SDK:\t $ANDROID_SDK_ROOT\n"
printf "======================================================\n"

_GradleVersion=

printf 'Checking gradle...\n'
_GradleExec=$(find $HOME/.gradle/wrapper/dists -type f -name "gradle" |tail -1)
printf "\e[32mFound gradle $_GradleExec\e[30m\n"

_GradlePluginVersion=$(ls $HOME/.gradle/caches/modules-2/files-2.1/com.android.tools.build/gradle |tail -1)
printf "\e[32mUse gradle plugin version $_GradlePluginVersion\e[30m\n"

_ApplyPlugin='com.android.application'
if [ -f "$_From/project.properties" ];then
	grep -q "android.library=true" $_From/project.properties && _ApplyPlugin='com.android.library' || _ApplyPlugin='com.android.application'
else
	printf "\e[31mCould not find $_From/project.properties, your project will convert to Android application project\e[30m\n"
fi

_TemplateGradle="
// auto generated script from $0

apply plugin: '$_ApplyPlugin'

android {
	compileSdkVersion 23
	buildToolsVersion '24.0.2'
	defaultConfig {
		minSdkVersion 10
		targetSdkVersion 23
		versionCode 1
		versionName '1.0'
	}
	buildTypes {
		release {
			minifyEnabled false
			proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
		}
	}
}
dependencies {
	compile fileTree(dir: 'libs', include: ['*.jar'])
	testCompile 'junit:junit:4.12'
	compile 'com.android.support:appcompat-v7:23.4.0'
}
"

_TemplateGradleTop="
// auto generated script from $0

buildscript {
    repositories {
        jcenter()
	}
	dependencies {
	    classpath 'com.android.tools.build:gradle:$_GradlePluginVersion'
    }
}
allprojects {
	repositories {
	    jcenter()
	}
}
"

declare -a _FILE_SRC_MAPS
declare -a _FILE_DEST_MAPS

_FILE_SRC_MAPS[0]='AndroidManifest.xml'
_FILE_SRC_MAPS[1]='lint.xml'
_FILE_SRC_MAPS[2]='res'
_FILE_SRC_MAPS[3]='src'
_FILE_SRC_MAPS[4]='jni'
_FILE_SRC_MAPS[5]='src'

_FILE_DEST_MAPS[0]='src/main/AndroidManifest.xml'
_FILE_DEST_MAPS[1]='../lint.xml'
_FILE_DEST_MAPS[2]='src/main/res'
_FILE_DEST_MAPS[3]='src/main/java'
_FILE_DEST_MAPS[4]='src/main/cpp'
_FILE_DEST_MAPS[5]='src/main/aidl'

if [ -d $_To/$_Name ];then
	echo "The module $_Name alread exists"
	echo "Quit!!!!!!!!!!!!!!!!!!!!"
	exit 0
fi

mkdir -p $_To/$_Name

echo "$_TemplateGradle" >> "$_To/$_Name/build.gradle"

if [ -f "$_To/settings.gradle" ];then
	printf "\e[31mYour project will be appended to $_To as a module\e[30m\n"
else
	printf "\e[31mCreate a new fresh project\e[30m\n"
	$_GradleExec -p $_To init wrapper
	echo "$_TemplateGradleTop" >> "$_To/build.gradle"
fi

echo "include ':$_Name'" >> "$_To/settings.gradle"

mkdir -p "$_To/$_Name/src/main"

for i in `seq 0 5`
do
	echo "Copy file or directory $_From/${_FILE_SRC_MAPS[$i]} ===> $_To/$_Name/${_FILE_DEST_MAPS[$i]}"
	[ -d "$_From/${_FILE_SRC_MAPS[$i]}" ] && cp -R -f "$_From/${_FILE_SRC_MAPS[$i]}" "$_To/$_Name/${_FILE_DEST_MAPS[$i]}"
	[ -f "$_From/${_FILE_SRC_MAPS[$i]}" ] && cp -f "$_From/${_FILE_SRC_MAPS[$i]}" "$_To/$_Name/${_FILE_DEST_MAPS[$i]}"
done

# handle aidl
find "$_To/$_Name/src/main/aidl" -name '*.java' -delete
find "$_To/$_Name/src/main/aidl" -type d -empty | xargs rmdir
find "$_To/$_Name/src/main/java" -name '*.aidl' -delete
find "$_To/$_Name/src/main/java" -type d -empty | xargs rmdir
