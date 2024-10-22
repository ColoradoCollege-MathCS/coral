# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('defaultAI.py', '.'),
        ('icons','icons'), 
	    ('images','images'),
        ('AboutPopup.qml','.'),
        ('ActionHandler.qml','.'), 
        ('ellipseSelect.qml','.'), 
        ('lassoShapes.qml','.'), 
        ('LoadFunctions.qml','.'), 
        ('main.qml','.'), 
        ('paintbrush.qml','.'), 
        ('rectangleSelect.qml','.'), 
        ('SaveLocationsPopup.qml','.'),
        ('shapes.qml','.'), 
        ('ToolFunctions.qml','.'), 
        ('vertex.qml','.'),
        ('SpeciesList.csv','.')
        ],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='CoralLabeler',
    icon='icons/CoralLabeler.ico',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='CoralLabeler',
)
app = BUNDLE(coll,
	name="CoralLabeler.app",
	icon='icons/CoralLabeler.icns',
	bundle_identifier=None
)
