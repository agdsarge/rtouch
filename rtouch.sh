# rtouch.sh
# Quickly generate component files for React. As an option, output a CSS file as well. 
# You may also import 'connect' from 'react-redux' and export a higher-order component with mapStateToProps and mapDispatchToProps.
#
# rtouch NewComponentName [func^class] [conn|redux] [css] 
# 
# if no valid name for the component is entered, the script creates a component called NewComponent
# this script defaults to class-based React components
# if you include both the option func and the option class components, this script will output the last last option
# e.g.
# rtouch MyComponent func css class #=> class component
# rtouch MyComponent class func css redux #=> functional component
#
# The patterns "class", "func", "conn", "redux", and "css" are reserved. 
# The reserved patterns cannot be used in a component name.

# # # # # # #

TRI="   ";
TAB="    ";

function import_lines {
    
    file="$1.js";
    if [[ $5 == 'class' ]]; then
        echo "import React, { Component } from 'react';" >> $file;
    else
        echo "import React from 'react';" >> $file;
    fi;
    if [[ -n $3 ]]; then echo "import { connect } from 'react-redux';" >> $file; fi;
    if [[ -n $4 ]]; then 
        import_line3="import './$1.css';"; 
        echo $import_line3 >> $file;
        echo "div.$2 {\n\n}" >> "$1".css;
    fi;
}

function map_state_and_dispatch {
    file="$1.js";
    echo "const mapStateToProps = (state) => {" >> $file;
    echo "$TRI return {\n\n$TRI }" >> $file;
    echo "}\n" >> $file;
    echo "const mapDispatchToProps = (dispatch) => {" >> $file;
    echo "$TRI return {\n\n$TRI }" >> $file;
    echo "}\n" >> $file;
    echo "export default connect(mapStateToProps, mapDispatchToProps)($1)" >> $file;
}

function generate_class_component {
    
    import_lines $@ class;

    file="$1.js";

    echo "\nclass $1 extends Component {" >> $file;
    if [ ! $3 ]; then echo "$TRI constructor(props) {\n\n}" >> $file; fi;
    echo "\n$TRI componentDidMount() {\n\n$TRI }" >> $file;
    echo "\n$TRI render() {" >> $file;
    echo "$TAB$TRI return (" >> $file;
    echo "$TAB$TAB$TRI <div className='$2'>\n" >> $file;
    echo "$TAB$TAB$TRI </div>" >> $file;
    echo "$TAB$TRI )" >> $file;
    echo "$TRI }" >> $file;
    echo "}\n" >> $file;

    if [[ $3 == true ]]; then
        map_state_and_dispatch $@;
    else
        echo "export default $1" >> $file;;
    fi;
}

function generate_functional_component {

    import_lines $@;

    file="$1.js";
    
    echo "\nfunction $1() {" >> $file;
    echo "$TRI return (" >> $file;
    echo "$TAB$TRI <div className='$2'>\n" >> $file;
    echo "$TAB$TRI </div>" >> $file;
    echo "$TRI )" >> $file;
    echo "}\n" >> $file;

    if [[ $3 == true ]]; then
        map_state_and_dispatch $@;
    else
        echo "export default $1" >> $file;
    fi;
}

function capitalize_component_name {
    echo "$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}";
}

function div_class_name {
    echo "$(tr '[:upper:]' '[:lower:]' <<< ${1:0:1})${1:1}";
}

function parse_arguments {
    # default values
    class_component=true;
    react_redux=false;
    css_gen=false;
    temp_name='';

    for ARG in $@
    do
        low_arg=$(tr '[:upper:]' '[:lower]' <<< $ARG);
        if [[ -n $(grep "class" <<< $low_arg) ]]; then
            class_component=true;
        elif [[ -n $(grep "css" <<< $low_arg) ]]; then 
            css_gen=true;
        elif [[ -n $(grep "func" <<< $low_arg) ]]; then
            class_component=false;
        elif [[ -n $(grep -E "conn|redux" <<< $low_arg) ]]; then
            react_redux=true;
        else 
            temp_name=$ARG;
        fi;
    done;
    
    if [[ -z $temp_name ]]; then temp_name='NewComponent'; fi;
    
    up_name=$(capitalize_component_name $temp_name);
    low_name=$(div_class_name $temp_name);
    
    if [[ -f "$up_name".js ]]; then
        echo "JS filename $up_name already exists in this directory.";
    else
        if $class_component; then
            generate_class_component $up_name $low_name $react_redux $css_gen;
        else
            generate_functional_component $up_name $low_name $react_redux $css_gen;
        fi;
    fi;
}

parse_arguments $@
