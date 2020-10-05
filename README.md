# rtouch
a shell script to produce react component files

Use rtouch to quickly generate component files for React.
    
    rtouch NewComponentName [func^class] [conn|redux] [css]

You can specify whether the component is class-based or functional. If empty, it defaults to a class-based component.
If you are using Redux, you can import connect from 'react-redux' and auto-generate mapStateToProps and mapDispatchToProps.
You may also generate a CSS file for this component.
