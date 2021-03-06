/**
 * Name: Backgrounder
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: allow applications to run in the background
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2010-05-13 23:27:36
 */

/**
 * Copyright (C) 2008-2010  Lance Fetters (aka. ashikase)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#import "DocumentationController.h"

#import "Constants.h"
#import "Preferences.h"


@implementation DocumentationController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Documentation";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
            style:UIBarButtonItemStyleBordered target:nil action:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Reset the table by deselecting the current selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
    return nil;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
    static int rows[] = {3, 3, 1};
    return rows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdSafari = @"SafariCell";
    static NSString *reuseIdSimple = @"SimpleCell";

    UITableViewCell *cell = nil;

    if (indexPath.section == 2) {
        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSafari];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdSafari] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.textLabel.text = @"Project Homepage";
            cell.detailTextLabel.text = @"(via Safari)";
        }
    } else {
        static NSString *cellTitles[][3] = {
            {@"About", @"How to Use", @"Frequently Asked Questions"},
            {@"Release Notes", @"Known Issues", @"Todo"}};

        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSimple];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdSimple] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = cellTitles[indexPath.section][indexPath.row];
    }

    return cell;
}

#pragma mark - UITableViewCellDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileNames[][3] = {
        {@"about.mdwn", @"usage.mdwn", @"faq.mdwn"},
        {@"release_notes.mdwn", @"known_issues.mdwn", @"todo.mdwn"}};

    if (indexPath.section == 2) {
        // Project Homepage
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@DEVSITE_URL]];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        // NOTE: Controller is released in delegate callback
        HtmlDocController *docCont = [[HtmlDocController alloc]
            initWithContentsOfFile:fileNames[indexPath.section][indexPath.row] templateFile:@"template.html" title:cell.textLabel.text];
        docCont.delegate = self;
    }
}

#pragma mark - HtmlDocController delegate

- (void)htmlDocControllerDidFinishLoading:(HtmlDocController *)docCont
{
    [[self navigationController] pushViewController:[docCont autorelease] animated:YES];
}

- (void)htmlDocControllerDidFailToLoad:(HtmlDocController *)docCont
{
    [docCont autorelease];
}

@end

/* vim: set filetype=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
