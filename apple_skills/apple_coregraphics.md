# Apple COREGRAPHICS Skill


## CGPDFArray
> https://developer.apple.com/documentation/coregraphics/cgpdfarray

### 
Many `CGPDFArray` functions to retrieve values from a PDF array take the form:
PDF arrays may be heterogeneous—that is, they may contain any other PDF objects, including PDF strings, PDF dictionaries, and other PDF arrays.
Many `CGPDFArray` functions to retrieve values from a PDF array take the form:
```objc
bool CGPDFArrayGet<DataType> (
 CGPDFArrayRef array,
 size_t index,
 <DataType>Ref *value
);
```


## CGPDFDictionary
> https://developer.apple.com/documentation/coregraphics/cgpdfdictionary

### 
Dictionary objects are the main building blocks of a PDF document. A key-value pair within a dictionary is called an entry. In a PDF dictionary, the key must be an array of characters. Within a given dictionary, the keys are unique—that is, no two keys in a single dictionary are equal (as determined by `strcmp`). The value associated with a key can be any kind of PDF object, including another dictionary. Dictionary objects are the main building blocks of a PDF document.
Many functions that retrieve values from a PDF dictionary take the form:
```objc
bool CGPDFDictionaryGet<DataType> (
 CGPDFDictionaryRef dictionary,
 const char *key,
 <DataType>Ref *value
);
```


