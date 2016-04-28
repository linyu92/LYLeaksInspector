//
//  LYLeaksDefined.h
//  Pods
//
//  Created by linyu on 4/28/16.
//
//

#ifdef LYLeaksDebug

    #define LYLeaksDebugActive LYLeaksDebug

#else

    #ifdef DEBUG

        #define LYLeaksDebugActive 1

    #endif

#endif




extern NSString * const kLeaksInspectorWarnNotification;
extern NSString * const kLeaksWarnClearNotification;

extern void SwizzleInstanceMethod(Class c, SEL origSEL, SEL newSEL);
extern void SwizzleClassMethod(Class c, SEL origSEL, SEL newSEL);

extern NSSet * LeaksInspectorWhiteListClass();
extern void AddLeaksInspectorWhiteListClass(NSString *classname);

extern NSSet * HeapEnumeratorDespiteClass();
extern void AddHeapEnumeratorDespiteClass(NSString *classname);

extern NSString * HeapObjectAddressPair(id obj);
extern NSString * AddressPointerForAddressPair(NSString *pair);
extern NSString * ClassNameForAddressPair(NSString *pair);



