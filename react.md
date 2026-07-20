"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import {
  ArrowRight,
  Award,
  CalendarDays,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  Home,
  Palette,
  Printer,
  UserRound,
} from "lucide-react";
import { getAuthUser } from "@/lib/auth";

type Gender = "student_male" | "student_female";

type CertificateForm = {
  gender: Gender;
  studentsBulk: string;
  schoolName: string;
  className: string;
  teacherName: string;
  principalName: string;
  certificateDate: string;
  reason: string;
  templateId: number;
};

type Template = {
  id: number;
  name: string;
  label: string;
  accent: string;
  dark: string;
  soft: string;
  gold: string;
  style:
    | "nationalRibbon"
    | "luxuryFrame"
    | "blueAcademic"
    | "royalGold"
    | "modernCorner"
    | "minimalStamp";
};

const templates: Template[] = [
  {
    id: 1,
    name: "قالب 1",
    label: "رسمي سعودي",
    accent: "#0E9F86",
    dark: "#065F55",
    soft: "#F4FFFB",
    gold: "#E2AD3B",
    style: "nationalRibbon",
  },
  {
    id: 2,
    name: "قالب 2",
    label: "إطار فاخر",
    accent: "#238B83",
    dark: "#163E47",
    soft: "#F8FCFB",
    gold: "#CFA44A",
    style: "luxuryFrame",
  },
  {
    id: 3,
    name: "قالب 3",
    label: "تعليمي أزرق",
    accent: "#2377B8",
    dark: "#153B5B",
    soft: "#F4FAFF",
    gold: "#E2AD3B",
    style: "blueAcademic",
  },
  {
    id: 4,
    name: "قالب 4",
    label: "ذهبي ملكي",
    accent: "#D7A13B",
    dark: "#20242B",
    soft: "#FFF9EC",
    gold: "#F0C96A",
    style: "royalGold",
  },
  {
    id: 5,
    name: "قالب 5",
    label: "زوايا حديثة",
    accent: "#16A085",
    dark: "#123C4A",
    soft: "#FFFDF8",
    gold: "#F4BE3B",
    style: "modernCorner",
  },
  {
    id: 6,
    name: "قالب 6",
    label: "ختم بسيط",
    accent: "#0E7A5E",
    dark: "#075244",
    soft: "#F7FCFA",
    gold: "#E2AD3B",
    style: "minimalStamp",
  },
];

const readyReasons = [
  "لتفوقه الدراسي وسمو أخلاقه، ونتمنى له دوام التفوق والنجاح بإذن الله.",
  "لتميزه في المشاركة الصفية والانضباط، مع تمنياتنا له بمزيد من التقدم.",
  "لجهوده المميزة في التحصيل الدراسي، وحرصه الدائم على التعلم.",
  "لتعاونه وحسن سلوكه داخل الصف، ونسأل الله له التوفيق والسداد.",
];

const today = new Date().toISOString().slice(0, 10);

const initialForm: CertificateForm = {
  gender: "student_male",
  studentsBulk: "",
  schoolName: "مدرسة حضّر النموذجية",
  className: "الصف الأول المتوسط",
  teacherName: "معلم تجريبي",
  principalName: "حكيم",
  certificateDate: today,
  reason: readyReasons[0],
  templateId: 1,
};

function getNames(value: string) {
  return value
    .split("\n")
    .map((name) => name.trim())
    .filter(Boolean);
}

function studentLabel(gender: Gender) {
  return gender === "student_female" ? "للطالبة" : "للطالب";
}

function adjustReason(reason: string, gender: Gender) {
  if (gender === "student_male") return reason;

  return reason
    .replaceAll("لتفوقه", "لتفوقها")
    .replaceAll("له", "لها")
    .replaceAll("جهوده", "جهودها")
    .replaceAll("حرصه", "حرصها")
    .replaceAll("تعاونه", "تعاونها")
    .replaceAll("سلوكه", "سلوكها");
}

export default function CertificatesPage() {
  const authUser = useMemo(() => getAuthUser(), []);
  const [form, setForm] = useState<CertificateForm>(() => ({
    ...initialForm,
    teacherName: authUser?.name || initialForm.teacherName,
  }));
  const [activeIndex, setActiveIndex] = useState(0);

  const template =
    templates.find((item) => item.id === form.templateId) || templates[0];
  const names = getNames(form.studentsBulk);
  const currentName = names[activeIndex] || "اسم الطالب";
  const printNames = names.length ? names : [currentName];
  const finalReason = adjustReason(form.reason, form.gender);

  const update = <K extends keyof CertificateForm>(
    key: K,
    value: CertificateForm[K],
  ) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const nextStudent = () => {
    if (!names.length) return;
    setActiveIndex((prev) => (prev + 1) % names.length);
  };

  const prevStudent = () => {
    if (!names.length) return;
    setActiveIndex((prev) => (prev === 0 ? names.length - 1 : prev - 1));
  };

  const handlePrint = () => {
    const printContent = document.querySelector(".certificates-print-source");

    if (!printContent) {
      window.print();
      return;
    }

    const styles = Array.from(
      document.querySelectorAll('link[rel="stylesheet"], style'),
    )
      .map((node) => node.outerHTML)
      .join("\n");

    const printWindow = window.open("", "_blank", "width=1200,height=850");

    if (!printWindow) {
      window.print();
      return;
    }

    printWindow.document.open();
    printWindow.document.write(`<!doctype html>
<html lang="ar" dir="rtl">
  <head>
    <meta charset="utf-8" />
    <title>طباعة الشهادات</title>
    ${styles}
    <style>
      @page {
        size: A4 landscape;
        margin: 0;
      }

      html,
      body {
        margin: 0 !important;
        padding: 0 !important;
        background: #fff !important;
        direction: rtl !important;
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }

      body {
        width: 297mm !important;
      }

      .certificates-print-root {
        width: 297mm !important;
        margin: 0 !important;
        padding: 0 !important;
        background: #fff !important;
      }

      .certificate-page {
        width: 287mm !important;
        height: 200mm !important;
        max-width: none !important;
        min-height: 0 !important;
        margin: 5mm auto !important;
        padding: 0 !important;
        border-radius: 0 !important;
        box-shadow: none !important;
        overflow: hidden !important;
        break-after: page !important;
        page-break-after: always !important;
        page-break-inside: avoid !important;
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }

      .certificate-page:last-child {
        break-after: auto !important;
        page-break-after: auto !important;
      }
    </style>
  </head>
  <body>
    <main class="certificates-print-root">
      ${printContent.innerHTML}
    </main>
    <script>
      window.addEventListener("load", function () {
        setTimeout(function () {
          window.focus();
          window.print();
        }, 300);
      });
    </script>
  </body>
</html>`);
    printWindow.document.close();
  };

  return (
    <main
      dir="rtl"
      className="min-h-screen bg-[radial-gradient(circle_at_top_left,rgba(226,173,59,0.12),transparent_30%),linear-gradient(135deg,#F8FFFC_0%,#EAF7F2_100%)] px-4 py-6 text-[#0B2D28]"
    >
      <style jsx global>{`
        .certificates-print-source {
          display: none;
        }

        @media print {
          .no-print,
          .certificates-print-source {
            display: none !important;
          }
        }
      `}</style>

      <div className="mx-auto grid max-w-[1700px] gap-5">
        <header className="no-print flex flex-wrap items-center justify-between gap-4 rounded-[32px] border border-[#DDEEE8] bg-white/90 p-5 shadow-[0_18px_55px_rgba(13,84,70,0.08)] backdrop-blur-xl">
          <div className="flex items-center gap-4">
            <Link
              href="/"
              className="grid h-12 w-12 place-items-center rounded-2xl border border-[#DDEEE8] bg-white text-[#0E7A5E]"
            >
              <ArrowRight size={18} />
            </Link>
            <div>
              <p className="inline-flex items-center gap-2 rounded-full bg-[#EAF7F2] px-3 py-1 text-[11px] font-black text-[#0E7A5E]">
                <Award size={13} />
                شهادات حضّر
              </p>
              <h1 className="mt-1 text-2xl font-black text-[#075244]">
                إنشاء شهادات شكر وتقدير
              </h1>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <div className="inline-flex h-11 items-center gap-3 rounded-2xl border border-[#DDEEE8] bg-white px-4 text-sm font-black text-[#075244]">
              <span className="grid h-8 w-8 place-items-center rounded-xl bg-[#EAF7F2] text-[#0E7A5E]">
                <UserRound size={17} />
              </span>
              <span>{authUser?.name || form.teacherName || "معلم حضّر"}</span>
            </div>

            <button
              type="button"
              onClick={handlePrint}
              className="inline-flex h-11 items-center gap-2 rounded-2xl bg-gradient-to-l from-[#0E7A5E] to-[#24B998] px-5 text-sm font-black text-white shadow-[0_14px_30px_rgba(14,122,94,0.20)]"
            >
              طباعة / حفظ PDF
              <Printer size={17} />
            </button>

            <Link
              href="/"
              className="inline-flex h-11 items-center gap-2 rounded-2xl border border-[#DDEEE8] bg-white px-5 text-sm font-black text-[#0E7A5E]"
            >
              الرئيسية
              <Home size={17} />
            </Link>
          </div>
        </header>

        <section className="grid gap-5 xl:grid-cols-[500px_minmax(0,1fr)]">
          <aside className="no-print rounded-[34px] border border-[#DDEEE8] bg-white/95 p-6 shadow-[0_18px_55px_rgba(13,84,70,0.08)] xl:sticky xl:top-5 xl:max-h-[calc(100vh-40px)] xl:overflow-y-auto">
            <div className="mb-5 flex items-center justify-between">
              <div>
                <p className="text-xs font-black text-[#0E7A5E]">
                  بيانات الشهادة
                </p>
                <h2 className="mt-1 text-xl font-black text-[#075244]">
                  اختاري القالب واملئي البيانات
                </h2>
              </div>
              <span className="grid h-11 w-11 place-items-center rounded-2xl bg-[#FFF7E3] text-[#D89C22]">
                <Palette size={20} />
              </span>
            </div>

            <div className="grid gap-4">
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => update("gender", "student_male")}
                  className={`h-14 rounded-2xl border text-sm font-black ${
                    form.gender === "student_male"
                      ? "border-[#0E7A5E] bg-[#EAF7F2] text-[#075244]"
                      : "border-[#DDEEE8] bg-white text-[#61736F]"
                  }`}
                >
                  طالب
                </button>
                <button
                  type="button"
                  onClick={() => update("gender", "student_female")}
                  className={`h-14 rounded-2xl border text-sm font-black ${
                    form.gender === "student_female"
                      ? "border-[#0E7A5E] bg-[#EAF7F2] text-[#075244]"
                      : "border-[#DDEEE8] bg-white text-[#61736F]"
                  }`}
                >
                  طالبة
                </button>
              </div>

              <div>
                <div className="mb-2 flex items-center justify-between">
                  <p className="text-xs font-black text-[#075244]">
                    قوالب الشهادة
                  </p>
                  <span className="rounded-full bg-[#EAF7F2] px-3 py-1 text-[11px] font-black text-[#0E7A5E]">
                    6 قوالب
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  {templates.map((item) => (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => update("templateId", item.id)}
                      className={`overflow-hidden rounded-2xl border bg-white text-right transition hover:-translate-y-1 ${
                        form.templateId === item.id
                          ? "border-[#0E7A5E] shadow-[0_18px_35px_rgba(14,122,94,0.18)]"
                          : "border-[#DDEEE8] shadow-sm"
                      }`}
                    >
                      <TemplateThumbnail template={item} />
                      <div className="flex items-center justify-between px-3 py-2">
                        <span className="text-sm font-black text-[#075244]">
                          {item.name}
                        </span>
                        {form.templateId === item.id && (
                          <CheckCircle2 size={16} className="text-[#0E7A5E]" />
                        )}
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              <Textarea
                label="أسماء الطلاب - كل اسم في سطر"
                placeholder="اكتبي أسماء الطلاب هنا..."
                value={form.studentsBulk}
                onChange={(value) => {
                  update("studentsBulk", value);
                  setActiveIndex(0);
                }}
                rows={5}
              />

              <div className="grid grid-cols-2 gap-3">
                <Input
                  label="اسم المدرسة"
                  value={form.schoolName}
                  onChange={(value) => update("schoolName", value)}
                />
                <Input
                  label="الصف"
                  value={form.className}
                  onChange={(value) => update("className", value)}
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <Input
                  label="اسم المعلم"
                  value={form.teacherName}
                  onChange={(value) => update("teacherName", value)}
                />
                <Input
                  label="اسم المدير"
                  value={form.principalName}
                  onChange={(value) => update("principalName", value)}
                />
              </div>

              <DateInput
                label="تاريخ الشهادة"
                value={form.certificateDate}
                onChange={(value) => update("certificateDate", value)}
              />

              <Textarea
                label="نص الشهادة"
                value={form.reason}
                onChange={(value) => update("reason", value)}
                rows={4}
              />

              <div className="grid gap-2">
                <p className="text-xs font-black text-[#075244]">نصوص جاهزة</p>
                {readyReasons.map((item) => (
                  <button
                    key={item}
                    type="button"
                    onClick={() => update("reason", item)}
                    className="rounded-2xl border border-[#DDEEE8] bg-[#F8FCFA] px-4 py-3 text-right text-xs font-bold leading-6 text-[#61736F] hover:border-[#0E7A5E] hover:text-[#075244]"
                  >
                    {adjustReason(item, form.gender)}
                  </button>
                ))}
              </div>
            </div>
          </aside>

          <section className="print-area rounded-[34px] border border-[#DDEEE8] bg-[#EDF8F4] p-4 shadow-[0_18px_55px_rgba(13,84,70,0.06)] sm:p-6">
            <div className="no-print mb-4 flex flex-wrap items-center justify-between gap-3 rounded-3xl border border-[#DDEEE8] bg-white p-4">
              <div>
                <p className="text-xs font-black text-[#0E7A5E]">
                  معاينة الشهادة
                </p>
                <h3 className="mt-1 text-xl font-black text-[#075244]">
                  {template.name} - {template.label}
                </h3>
                <p className="mt-1 text-xs font-bold text-[#61736F]">
                  {names.length || 1} شهادة جاهزة للطباعة
                </p>
              </div>

              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={prevStudent}
                  className="grid h-10 w-10 place-items-center rounded-2xl border border-[#DDEEE8] bg-white text-[#0E7A5E]"
                >
                  <ChevronRight size={18} />
                </button>
                <span className="min-w-[90px] text-center text-sm font-black text-[#075244]">
                  {Math.min(activeIndex + 1, Math.max(names.length, 1))}/
                  {Math.max(names.length, 1)}
                </span>
                <button
                  type="button"
                  onClick={nextStudent}
                  className="grid h-10 w-10 place-items-center rounded-2xl border border-[#DDEEE8] bg-white text-[#0E7A5E]"
                >
                  <ChevronLeft size={18} />
                </button>
              </div>
            </div>

            <div className="mx-auto max-w-[1120px] overflow-auto rounded-[26px] bg-white p-3">
              <CertificatePreview
                template={template}
                form={form}
                studentName={currentName}
                reason={finalReason}
              />
            </div>
          </section>

          <section className="certificates-print-source" aria-hidden="true">
            {printNames.map((studentName, index) => (
              <CertificatePreview
                key={`${studentName}-${index}`}
                template={template}
                form={form}
                studentName={studentName}
                reason={finalReason}
              />
            ))}
          </section>
        </section>
      </div>
    </main>
  );
}

function TemplateThumbnail({ template }: { template: Template }) {
  return (
    <div
      className="relative h-28 overflow-hidden"
      style={{ background: template.soft }}
    >
      <div
        className="absolute inset-x-0 top-0 h-12"
        style={{
          background:
            template.style === "royalGold"
              ? `linear-gradient(135deg, ${template.dark}, #4A3416, ${template.accent})`
              : `linear-gradient(135deg, ${template.accent}, ${template.dark})`,
        }}
      />
      <div className="absolute left-4 top-4 h-6 w-10 rounded-lg bg-white/85" />
      <div className="absolute right-4 top-4 h-6 w-10 rounded-lg bg-white/85" />
      <div className="absolute left-1/2 top-14 h-2.5 w-36 -translate-x-1/2 rounded-full bg-slate-300" />
      <div className="absolute left-1/2 top-19 h-2 w-24 -translate-x-1/2 rounded-full bg-slate-200" />
      <div
        className="absolute bottom-0 left-0 h-8 w-32 rounded-tr-[42px]"
        style={{ background: template.accent, opacity: 0.72 }}
      />
      <div
        className="absolute bottom-0 right-0 h-8 w-32 rounded-tl-[42px]"
        style={{ background: template.dark, opacity: 0.72 }}
      />
      {template.style === "modernCorner" && (
        <>
          <div className="absolute left-0 top-0 h-14 w-14 bg-[#F4436C]" />
          <div className="absolute right-0 bottom-0 h-14 w-14 bg-[#2377B8]" />
        </>
      )}
    </div>
  );
}

function CertificatePreview({
  template,
  form,
  studentName,
  reason,
}: {
  template: Template;
  form: CertificateForm;
  studentName: string;
  reason: string;
}) {
  return (
    <article
      className="certificate-page relative mx-auto aspect-[1.414/1] w-[1080px] max-w-full overflow-hidden bg-white text-[#263238] shadow-[0_16px_40px_rgba(15,23,42,0.12)]"
      style={
        {
          "--cert-accent": template.accent,
          "--cert-dark": template.dark,
          "--cert-soft": template.soft,
          "--cert-gold": template.gold,
        } as React.CSSProperties
      }
    >
      <CertificateBg template={template} />

      <div className="relative z-10 flex h-full flex-col px-20 py-12">
        <div
          dir="ltr"
          className="flex items-start justify-center gap-5"
          aria-label="شعارات وزارة التعليم ورؤية السعودية 2030"
        >
          {/* رؤية 2030 على اليسار */}
          <LogoSlot
            src="/vision-2030-logo.png"
            fallbackTop="رؤية"
            fallbackBottom="2030"
            imageClassName="h-[72px] w-[104px] object-contain"
          />

          {/* وزارة التعليم على اليمين */}
          <LogoSlot
            src="/ministry-logo.png"
            fallbackTop="وزارة"
            fallbackBottom="التعليم"
            imageClassName="h-[78px] w-[112px] scale-[1.16] object-contain"
          />
        </div>

        <div className="mt-8 text-center">
          <p className="text-5xl font-black text-[var(--cert-dark)] drop-shadow-sm">
            شهادة شكر وتقدير
          </p>
          <p className="mt-4 text-2xl font-bold text-slate-600">
            يسر إدارة مدرسة
            <span className="mx-3 inline-flex min-w-[285px] justify-center rounded-full bg-[var(--cert-accent)] px-8 py-2 text-white shadow-md">
              {form.schoolName}
            </span>
            أن تتقدم بوافر الشكر والتقدير
          </p>
        </div>

        <div className="mt-8 grid items-center gap-5 text-2xl font-bold md:grid-cols-[1fr_auto_1.25fr_auto]">
          <span className="text-left text-slate-600">
            {studentLabel(form.gender)}
          </span>
          <span className="min-w-[420px] rounded-full bg-gradient-to-l from-[var(--cert-accent)] to-[var(--cert-dark)] px-8 py-3 text-center text-3xl font-black text-white shadow-lg">
            {studentName}
          </span>
          <span className="rounded-full bg-[var(--cert-accent)] px-8 py-3 text-center text-white shadow-md">
            {form.className}
          </span>
          <span className="text-slate-600">الصف</span>
        </div>

        <p className="mx-auto mt-10 max-w-[850px] text-center text-3xl font-bold leading-[1.85] text-slate-800">
          {reason}
        </p>

        <div className="mt-auto grid grid-cols-3 items-end gap-8">
          <Signature title="المدير" name={form.principalName} />
          <div className="grid justify-items-center gap-3">
            <div className="grid h-24 w-24 place-items-center rounded-full border-[5px] border-[var(--cert-accent)] bg-white/70 text-center text-[11px] font-black leading-5 text-[var(--cert-dark)] shadow-xl">
              شهادة
              <br />
              حضّر
            </div>
            <p className="rounded-full bg-[var(--cert-soft)] px-5 py-2 text-sm font-black text-[var(--cert-dark)]">
              {form.certificateDate}
            </p>
          </div>
          <Signature title="المعلم" name={form.teacherName} />
        </div>
      </div>
    </article>
  );
}

function CertificateBg({ template }: { template: Template }) {
  if (template.style === "nationalRibbon") {
    return (
      <>
        <div className="absolute inset-x-0 top-0 h-[215px] bg-gradient-to-br from-[var(--cert-accent)] to-[var(--cert-dark)]" />
        <div className="absolute inset-x-[-6%] top-[132px] h-[120px] rounded-[0_0_50%_50%] bg-white" />
        <div className="absolute inset-x-14 top-[236px] h-px bg-[var(--cert-accent)]/25" />
        <Pattern />
      </>
    );
  }

  if (template.style === "luxuryFrame") {
    return (
      <>
        <div className="absolute inset-0 bg-[var(--cert-soft)]" />
        <div className="absolute inset-8 rounded-[44px] border-[4px] border-[var(--cert-accent)]/35" />
        <div className="absolute inset-14 rounded-[34px] border border-[var(--cert-accent)]/35" />
        <div className="absolute left-10 top-10 h-24 w-24 rounded-br-[80px] border-l-[8px] border-t-[8px] border-[var(--cert-accent)]" />
        <div className="absolute right-10 bottom-10 h-24 w-24 rounded-tl-[80px] border-b-[8px] border-r-[8px] border-[var(--cert-accent)]" />
      </>
    );
  }

  if (template.style === "royalGold") {
    return (
      <>
        <div className="absolute inset-0 bg-[var(--cert-soft)]" />
        <div className="absolute inset-x-0 top-0 h-36 bg-gradient-to-l from-[var(--cert-dark)] via-[#3B2F1E] to-[var(--cert-dark)]" />
        <div className="absolute inset-x-20 top-12 h-28 rounded-b-[100px] border-b-[12px] border-[var(--cert-gold)]" />
        <div className="absolute inset-10 rounded-[42px] border-[3px] border-[var(--cert-gold)]/75" />
        <Pattern />
      </>
    );
  }

  if (template.style === "modernCorner") {
    return (
      <>
        <div className="absolute inset-0 bg-white" />
        <div
          className="absolute left-0 top-0 h-64 w-52 bg-[#F4436C]"
          style={{ clipPath: "polygon(0 0,100% 0,0 100%)" }}
        />
        <div
          className="absolute right-0 top-0 h-64 w-52 bg-[#FFC857]"
          style={{ clipPath: "polygon(0 0,100% 0,100% 100%)" }}
        />
        <div
          className="absolute bottom-0 left-0 h-56 w-52 bg-[#0E9F86]"
          style={{ clipPath: "polygon(0 0,0 100%,100% 100%)" }}
        />
        <div
          className="absolute bottom-0 right-0 h-56 w-52 bg-[#2377B8]"
          style={{ clipPath: "polygon(100% 0,0 100%,100% 100%)" }}
        />
      </>
    );
  }

  return (
    <>
      <div className="absolute inset-0 bg-[var(--cert-soft)]" />
      <div className="absolute inset-8 rounded-[40px] border-[3px] border-[var(--cert-accent)]/30" />
      <div className="absolute inset-x-0 top-0 h-28 bg-gradient-to-l from-[var(--cert-accent)] to-[var(--cert-dark)]" />
      <Pattern />
    </>
  );
}

function Pattern() {
  return (
    <div className="absolute inset-0 opacity-[0.08] [background-image:radial-gradient(circle_at_20px_20px,#000_2px,transparent_0)] [background-size:42px_42px]" />
  );
}

function LogoSlot({
  src,
  fallbackTop,
  fallbackBottom,
  imageClassName = "max-h-full max-w-full object-contain",
}: {
  src: string;
  fallbackTop: string;
  fallbackBottom: string;
  imageClassName?: string;
}) {
  const [failed, setFailed] = useState(false);

  return (
    <div className="grid h-24 w-32 place-items-center overflow-hidden rounded-3xl bg-white/95 p-2 shadow-[0_12px_28px_rgba(15,23,42,0.14)] ring-1 ring-black/5">
      {!failed ? (
        <img
          src={src}
          alt={`${fallbackTop} ${fallbackBottom}`}
          className={imageClassName}
          onError={() => setFailed(true)}
        />
      ) : (
        <span className="text-center text-[12px] font-black leading-5 text-[var(--cert-dark)]">
          {fallbackTop}
          <br />
          {fallbackBottom}
        </span>
      )}
    </div>
  );
}

function Signature({ title, name }: { title: string; name: string }) {
  return (
    <div className="text-center">
      <p className="text-2xl font-bold text-slate-900">{title}</p>
      <div className="mx-auto mt-3 h-1 w-56 rounded-full bg-[var(--cert-accent)]" />
      <p className="mt-4 text-2xl font-bold text-slate-900">{name}</p>
    </div>
  );
}

function Input({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="grid gap-1.5">
      <span className="text-xs font-black text-[#075244]">{label}</span>
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="h-11 rounded-2xl border border-[#DDEEE8] bg-[#F8FCFA] px-4 text-sm font-bold text-[#102A43] outline-none transition focus:border-[#0E7A5E]"
      />
    </label>
  );
}

function DateInput({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label className="grid gap-1.5">
      <span className="text-xs font-black text-[#075244]">{label}</span>
      <div className="relative">
        <CalendarDays
          size={17}
          className="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-[#0E7A5E]"
        />
        <input
          type="date"
          value={value}
          onChange={(event) => onChange(event.target.value)}
          className="h-11 w-full rounded-2xl border border-[#DDEEE8] bg-[#F8FCFA] px-4 pr-11 text-sm font-bold text-[#102A43] outline-none transition focus:border-[#0E7A5E]"
        />
      </div>
    </label>
  );
}

function Textarea({
  label,
  value,
  onChange,
  rows = 3,
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  rows?: number;
  placeholder?: string;
}) {
  return (
    <label className="grid gap-1.5">
      <span className="text-xs font-black text-[#075244]">{label}</span>
      <textarea
        value={value}
        rows={rows}
        placeholder={placeholder}
        onChange={(event) => onChange(event.target.value)}
        className="resize-none rounded-2xl border border-[#DDEEE8] bg-[#F8FCFA] px-4 py-3 text-sm font-bold leading-7 text-[#102A43] outline-none transition placeholder:text-[#9BAAA6] focus:border-[#0E7A5E]"
      />
    </label>
  );
}