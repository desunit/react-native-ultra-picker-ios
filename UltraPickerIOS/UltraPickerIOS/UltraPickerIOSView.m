//
//  UPIView.m
//  Ultra-Picker-iOS
//
//  Created by Tim Sawtell on 3/9/17.
//  Copyright © 2017 Sportsbet. All rights reserved.
//

#import "UltraPickerIOSView.h"

@interface UltraPickerIOSView() <UIPickerViewDataSource, UIPickerViewDelegate>

@end

NSInteger const UIPickerDefaultFontSize = 17.0;
NSString const *UIPickerDefaultFontFamily = @"HelveticaNeue";

@implementation UltraPickerIOSView

- (void) setComponentsData:(NSArray *)componentsData
{
    if (componentsData != _componentsData) {
        _componentsData = [componentsData copy];
        [self setNeedsLayout];
        
        if (_selectedIndexes)
            [self setSelectedIndexes:_selectedIndexes];
    }
}

- (void) setSelectedIndexes:(NSArray<NSNumber *> *)selectedIndexes
{
    _selectedIndexes = selectedIndexes;
    if (!self.componentsData) {
        return;
    }
    for (NSInteger i = 0; i < selectedIndexes.count; i++) {
        NSInteger index = [selectedIndexes[i] integerValue];
        [self selectRow:index inComponent:i animated:NO];
    }
}

- (void) setTestID:(NSString *)testID
{
    _testID = testID;
    self.accessibilityIdentifier = testID;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Never return zero, or the selection indicator lines won't render
    return MAX(self.componentsData.count, 1);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // Never return zero, or the selection indicator lines won't render
    return MAX([[[self.componentsData objectAtIndex:component] valueForKey:@"items"] count], 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self labelForRow:row forComponent:component];
}

- (NSString *)labelForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"label"];
    if (!text) {
        return @"";
    } else {
        return text;
    }
}

- (NSString *)labelForRow2:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"label2"];
    if (!text) {
        return @"";
    } else {
        return text;
    }
}

-(void)initLabel:(UILabel*)label forRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *fontName;
    NSInteger fontSize;
    UIFont *font = nil;
    
    //Check for property on the Item first, then the Group
    NSString *itemFontFamily = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"fontFamily"];
    NSString *itemFontSize = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"fontSize"];
    
    if (itemFontFamily != nil || itemFontSize != nil) {
        fontName = itemFontFamily ?: UIPickerDefaultFontFamily;
        fontSize = itemFontSize.integerValue > 0 ? itemFontSize.integerValue : UIPickerDefaultFontSize;
    }else {
        NSString *groupFontFamily = [[self.componentsData objectAtIndex:component] valueForKey:@"fontFamily"];
        NSString *groupFontSize = [[self.componentsData objectAtIndex:component] valueForKey:@"fontSize"];
        fontName = groupFontFamily ?: UIPickerDefaultFontFamily;
        fontSize = groupFontSize.integerValue > 0 ? groupFontSize.integerValue : UIPickerDefaultFontSize;
    }
    
    font = [UIFont fontWithName:fontName size:fontSize];
    
    if (font) {
        label.font = font;
    }
    
    [label setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *displayLabel;
    UILabel *displayLabel2;
    UIView *returnLabel;
    
    NSString *label2 = [self labelForRow2:row forComponent:component];
    
    if (view) {
        UIView *returnLabel = (UIView *)view;

        displayLabel = (UILabel *)[returnLabel.subviews objectAtIndex:0];
        if (label2)
            displayLabel2 = (UILabel *)[returnLabel.subviews objectAtIndex:1];
    }else {
        returnLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 30)];
        [returnLabel setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight];

        displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width / 3, 30)];
        [returnLabel addSubview:displayLabel];
        
        if (label2) {
            displayLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(displayLabel.frame.size.width + 10, 0, (pickerView.frame.size.width / 3) * 2, 30)];
            [returnLabel addSubview:displayLabel2];
        }
        [self initLabel:displayLabel forRow:row forComponent:component];
        [self initLabel:displayLabel2 forRow:row forComponent:component];
        
        displayLabel.textAlignment = NSTextAlignmentRight;
        displayLabel2.textAlignment = NSTextAlignmentLeft;
    }
    
    displayLabel.text = [self labelForRow:row forComponent:component];
    if (label2)
        displayLabel2.text = [self labelForRow2:row forComponent:component];

    return returnLabel;
}

- (NSString *)valueForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *text = [[[[self.componentsData objectAtIndex:component] valueForKey:@"items"] objectAtIndex:row] valueForKey:@"value"];
    if (!text) {
        return @"";
    } else {
        return text;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *event = @{
                            @"newIndex": @(row),
                            @"component": @(component),
                            @"newValue": [self valueForRow:row forComponent:component],
                            @"newLabel": [self labelForRow:row forComponent:component]
                            };
    
    if (self.onChange) {
        self.onChange(event);
    }
}

@end
