
Parse C header file by Eclipse CDT
===================================

At some situation if you want to parse C header from Java, you can use CDT in eclipse project.

To perform the parse, we need import two jars into our project.

1. first jar, [cdt.core](https://raw.githubusercontent.com/ricardojlrufino/eclipse-cdt-standalone-astparser/master/lib/org/eclipse/cdt.core/5.6.0.201402142303/cdt.core-5.6.0.201402142303.jar)
2. second jar, [equinox.common](https://raw.githubusercontent.com/ricardojlrufino/eclipse-cdt-standalone-astparser/master/lib/org/eclipse/equinox.common/3.6.200.v20130402-1505/equinox.common-3.6.200.v20130402-1505.jar)

Then starting from `org.eclipse.cdt.core.model.AbstractLanguage` to build an AST (Abstract Syntax Tree), and use
an `Visitor` to access the AST.

Below is an simple example to get all member function of `JNINativeInterface` from header file `jni.h`

```java
public void parseJNIHeaderWithCDT() {

        final String NDK_ROOT = System.getenv("ANDROID_NDK_ROOT");
        FileContent content = FileContent.createForExternalFileLocation(
                NDK_ROOT + File.separator + "sysroot/usr/include/jni.h");

        try {
            IASTTranslationUnit translationUnit = GPPLanguage.getDefault()
                    .getASTTranslationUnit(content,
                    new ScannerInfo(),
                    IncludeFileContentProvider.getEmptyFilesProvider(),
                    new CIndex(new IIndexFragment[0]),
                    0,
                    new DefaultLogService());

            ASTVisitor visitor = new ASTGenericVisitor(true) {
                @Override
                public int visit(IASTName name) {
                    if ("JNINativeInterface".equals(name.toString())
                            && name.isDefinition()) {
                    }
                    return super.visit(name);
                }

                @Override
                public int visit(final IASTDeclaration declaration) {
                    if (declaration instanceof CPPASTSimpleDeclaration) {
                        IASTNode parent = declaration.getParent();
                        if (parent instanceof CPPASTCompositeTypeSpecifier) {

                            final String parentName = ((CPPASTCompositeTypeSpecifier) parent).getName().toString();
                            final int key = ((CPPASTCompositeTypeSpecifier) parent).getKey();

                            if ("JNINativeInterface".equals(parentName)
                                    && (key == IASTCompositeTypeSpecifier.k_struct)) {
                                declaration.accept(new ASTGenericVisitor(true) {
                                    @Override
                                    public int visit(IASTDeclaration declaration) {
                                        return super.visit(declaration);
                                    }

                                    @Override
                                    public int visit(IASTDeclarator declarator) {
                                        if (declarator.getName() != null && declarator.getName().toString().length() > 0) {
                                            System.out.println("function pointer member in JNINativeInterface -> " + declarator.getName().toString());
                                        }
                                        return super.visit(declarator);
                                    }
                                });
                            }
                        }
                    } else if (declaration instanceof CPPASTFunctionDefinition) {
                        CPPASTFunctionDefinition functionDefinition = ((CPPASTFunctionDefinition) declaration);
                        if (functionDefinition.getParent() instanceof CPPASTCompositeTypeSpecifier) {
                            final CPPASTCompositeTypeSpecifier parent = (CPPASTCompositeTypeSpecifier) functionDefinition.getParent();
                            final String parentName = parent.getName().toString();
                            final String funcName = ((CPPASTFunctionDefinition) declaration).getDeclarator().getName().toString();
                        }
                    }
                    return super.visit(declaration);
                }
            };
            translationUnit.accept(visitor);
        } catch (CoreException e) {
            e.printStackTrace();
        }
    }
```

#### Reference
Many thanks to these pioneer work
* [Stackoverflow answer](https://stackoverflow.com/questions/10300021/parsing-reading-c-header-files-using-java)
* [Github repository](https://github.com/ricardojlrufino/eclipse-cdt-standalone-astparser)
